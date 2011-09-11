# encoding: utf-8
require 'spec'
require 'f2b'

describe "Status" do
  
  before :all do
    @situacao = F2b::Cobranca::Status.new
    @situacao.mensagem = {:data => Date.today.to_s, :numero => "000000001"}
    @situacao.cliente = {:conta => "3712897519713890", :senha => "morales"}
    @situacao.cobranca = {:numero => "000000001", :registro => "", :vencimento => "", :processamento => "", :credito => ""}
    @situacao = @situacao.submit!
  end
  
  it "should be sent without any errors" do
    @situacao.should == "OK\r\n"
  end

end
