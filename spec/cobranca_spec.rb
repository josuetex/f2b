# encoding: utf-8
require 'spec'
require 'f2b'

describe "Cobranca" do
  
  before :all do
    @cobranca = F2b::Cobranca.new
    @cobranca.numero = "000000001"
    @cobranca.sacador = {:conta => "5718973289173910", :senha => "morales", :nome => "Susan Morales"}
    @cobranca.cobranca = {:valor => 10.00}
    @cobranca.demonstrativo.concat ["Mensalidade"]
    @cobranca.agendamento = {:vencimento => (Date.today + 5).to_s, :periodos => 12, :titulo => "Mensalidade"}
    @cobranca.sacados.push({:nome => "Sheng Hou", :email => "teste@f2b.com.br", :envio => "e"})
    @cobranca = @cobranca.submit!
  end
  
  it "should be sent without any errors" do
    @cobranca.should == "OK\r\nTESTE"
  end
  
end
