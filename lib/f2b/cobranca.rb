# encoding: utf-8
module F2b
  class Cobranca < Handsoap::Service
    endpoint :uri => "https://www.f2b.com.br/WSBilling", :version => 1
    
    attr_accessor :numero
    attr_accessor :sacador
    attr_accessor :cobranca
    attr_reader :demonstrativo
    attr_accessor :desconto
    attr_accessor :multa
    attr_accessor :agendamento
    attr_reader :sacados
    
    def initialize
      @demonstrativo = []
      @sacados = []
    end
    
    def on_create_document(doc)
      doc.alias 'wsb', 'http://www.f2b.com.br/soap/wsbilling.xsd'
    end
    
    def on_response_document(doc)
      doc.add_namespace 'm', 'http://www.f2b.com.br/soap/wsbilling.xsd'
    end
    
    def submit!
      response = invoke("wsb:F2bCobranca") do |message|
        message.add "mensagem" do |m|
          m.set_attr "data", Date.today.to_s
          m.set_attr "numero", @numero unless @numero.nil?
          m.set_attr "tipo_ws", "WebService"
        end
        
        message.add "sacador" do |s|
          s.set_attr "conta", @sacador.fetch(:conta)
          s.set_attr "senha", @sacador.fetch(:senha)
          s.set_value @sacador.fetch(:nome)
        end
        
        if @cobranca
          message.add "cobranca" do |c|
            c.set_attr "valor", @cobranca.fetch(:valor)
            c.set_attr "tipo_cobranca", @cobranca.fetch(:tipo_cobranca) if @cobranca.has_key? :tipo_cobranca
            c.set_attr "num_document", @cobranca.fetch(:num_document) if @cobranca.has_key? :num_document
            c.set_attr "cod_banco", @cobranca.fetch(:cod_banco) if @cobranca.has_key? :cod_banco
            
            @demonstrativo.each do |value|
              c.add "demonstrativo", value
            end
            
            if @desconto
              c.add "desconto" do |d|
                d.set_attr "valor", @desconto.fetch(:valor)
                d.set_attr "tipo_desconto", @desconto.fetch(:tipo_desconto)
                d.set_attr "antecedencia", @desconto.fetch(:antecedencia)
              end
            end
            
            if @multa
              c.add "multa" do |m|
                m.set_attr "valor", @multa.fetch(:valor)
                m.set_attr "tipo_multa", @multa.fetch(:tipo_multa)
                m.set_attr "valor_dia", @multa.fetch(:valor_dia)
                m.set_attr "tipo_multa_dia", @multa.fetch(:tipo_multa_dia)
                m.set_attr "atraso", @multa.fetch(:atraso)
              end
            end
          end
          
          message.add "agendamento" do |a|
            a.set_attr "vencimento", @agendamento.fetch(:vencimento)
            a.set_attr "ultimo_dia", @agendamento.fetch(:ultimo_dia) if @agendamento.has_key? :ultimo_dia
            a.set_attr "antecedencia", @agendamento.fetch(:antecedencia) if @agendamento.has_key? :antecedencia
            a.set_attr "periodicidade", @agendamento.fetch(:periodicidade) if @agendamento.has_key? :periodicidade
            a.set_attr "periodos", @agendamento.fetch(:periodos) if @agendamento.has_key? :periodos
            a.set_attr "sem_vencimento", @agendamento.fetch(:sem_vencimento) if @agendamento.has_key? :sem_vencimento
            a.set_value @agendamento.fetch(:titulo) if @agendamento.has_key? :titulo
          end
        end
        
        # 1 ou mais sacados
        @sacados.each do |sacado|
          message.add "sacado" do |s|
            s.set_attr "grupo", sacado.fetch(:grupo) if sacado.has_key? :grupo
            s.set_attr "codigo", sacado.fetch(:codigo) if sacado.has_key? :codigo
            s.set_attr "envio", sacado.fetch(:envio) if sacado.has_key? :envio
            s.set_attr "atualizar", sacado.fetch(:atualizar) if sacado.has_key? :atualizar
            
            s.add "nome", sacado.fetch(:nome)
            s.add "email", sacado.fetch(:email)
            
            build_address!(s, sacado[:endereco]) if sacado.has_key? :endereco
            build_phones!(s, sacado)
            
            s.add "cpf", sacado.fetch(:cpf) if sacado.has_key? :cpf
            s.add "cnpj", sacado.fetch(:cnpj) if sacado.has_key? :cnpj
            s.add "observacao", sacado.fetch(:observacao) if sacado.has_key? :observacao
          end
        end
      end
      
      parse_response(response)
    end
    
    private
    
    def parse_response(response)
      cobrancas = []
      message = CGI.unescapeHTML((response/"//log").to_s)
      
      if message.include? "ERRO"
        raise message
      else
        (response/"//cobranca").each do |node|
          p node
          cobranca = {}          
          cobranca[:nome] = node/"nome".to_s
          cobranca[:email] = node/"email".to_s
          cobranca[:url] = node/"url".to_s
          cobrancas.push(cobranca)
        end
      end
      
      cobrancas.empty? ? message : cobrancas
    end
    
    def build_address!(node, address)
      node.add "endereco" do |e|
        e.set_attr "logradouro", address.fetch(:logradouro)
        e.set_attr "numero", address.fetch(:numero)
        e.set_attr "complemento", address.fetch(:complemento) if address.has_key? :complemento
        e.set_attr "bairro", address.fetch(:bairro) if address.has_key? :bairro
        e.set_attr "cidade", address.fetch(:cidade)
        e.set_attr "estado", address.fetch(:estado)
        e.set_attr "cep", address.fetch(:cep)
      end
    end
    
    def build_phones!(node, source)
      phones = source.select { |k, v| [:telefone, :telefone_com, :telefone_cel].include? k }
      
      phones.each do |key|
        type = key.to_s.gsub("_\w+$").to_s
        prefix = source[key][:ddd]
        number = source[key][:numero]
        
        node.add(key.to_s) do |p|
          p.set_attr "ddd#{type}", prefix
          p.set_attr "numero#{type}", number
        end
      end
    end
  end
end