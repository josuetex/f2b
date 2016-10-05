# encoding: utf-8
module F2b
  class Cobranca::Status < Handsoap::Service
    endpoint :uri => "https://www.f2b.com.br/WSBillingStatus", :version => 1
    
    attr_accessor :mensagem
    attr_accessor :cliente
    attr_accessor :cobranca
    
    def on_create_document(doc)
      doc.alias 'wsb', 'http://www.f2b.com.br/soap/wsbillingstatus.xsd'
    end
    
    def on_response_document(doc)
      doc.add_namespace 'm', 'http://www.f2b.com.br/soap/wsbillingstatus.xsd'
    end
    
    def submit!
      response = invoke("wsb:F2bSituacaoCobranca") do |message|
        message.add "mensagem" do |m|
          m.set_attr "data", @mensagem.fetch(:data)
          m.set_attr "numero", @mensagem.fetch(:numero)
        end
        
        message.add "cliente" do |c|
          c.set_attr "conta", @cliente.fetch(:conta)
          c.set_attr "senha", @cliente.fetch(:senha)
        end
        
        message.add "cobranca" do |c|
          build_chooseable_attr! c, :numero, @cobranca
          build_chooseable_attr! c, :registro, @cobranca
          build_chooseable_attr! c, :vencimento, @cobranca
          build_chooseable_attr! c, :processamento, @cobranca
          build_chooseable_attr! c, :credito, @cobranca
          
          c.set_attr "cod_sacado", @cobranca.fetch(:cod_sacado) if @cobranca.has_key? :cod_sacado
          c.set_attr "cod_grupo", @cobranca.fetch(:cod_grupo) if @cobranca.has_key? :cod_grupo
          c.set_attr "tipo_pagamento", @cobranca.fetch(:tipo_pagamento) if @cobranca.has_key? :tipo_pagamento
          c.set_attr "numero_documento", @cobranca.fetch(:numero_documento) if @cobranca.has_key? :numero_documento
        end
      end
      
      parse_response(response)
    end
    
    private
    
    def build_chooseable_attr!(node, name, source)
      other = "#{name.to_s}_final".to_sym
      
      if source.has_key? name
        node.set_attr(name.to_s, source.fetch(name))
      elsif source.has_key? other
        node.set_attr(other.to_s, source.fetch(other))
      end
    end
    
    def parse_response(response)
      cobranca = {}
      message = CGI.unescapeHTML((response/"//log").to_s)
      
      if message.include? "ERRO"
        raise message
      else
	document = Nokogiri::XML(response.http_response.body)
        document.xpath("//cobranca").each do |node|
          node.attributes.each_pair do |key, value|
            cobranca[key.to_sym] = value.value
          end        
          
          #node.xpath("*").each do |n|
          #  nodename = n.nodename.to_sym
          #  cobranca[nodename] = n.to_s
          #end
        end
      end
      
      cobranca.empty? ? message : cobranca
    end
  end
end
