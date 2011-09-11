F2b
===

Gem para integração com o serviço de pagamentos da [F2b](http://f2b.com.br).

Instalação
----------

### RubyGems ###

    sudo gem install f2b

Depois insira o código de importação em algum lugar do seu projeto.

    require 'rubygems'  
    require 'f2b'

### Bundler ###

Se estiver usando o [Bundler](http://github.com/carlhuda/bundler) adicione a seguinte linha no seu Gemfile.

    gem 'f2b'

Como usar
---------

#### cobrancas_controller.rb (Rails) ####

    def create
      cobranca = F2b::Cobranca.new
      cobranca.sacador = {:conta => "9023010001230123", :senha => "zero"}
      # cobranca...
      resposta = cobranca.submit!
      # render stuff
    end

Exemplo
-------

    cobranca = F2b::Cobranca.new
    cobranca.sacador = {:conta => "3127519739821794", :senha => "laszlo", :nome => "Pirate Laszlo the Bald"}
    cobranca.cobranca = {:valor => 10.00}
    cobranca.demonstrativo.concat ["Mensalidade"]
    cobranca.agendamento = {:vencimento => (Date.today + 5).strftime, :periodos => 12, :titulo => "Mensalidade"}
    cobranca.sacados.push({:nome => "Sheng Hou", :email => "teste@f2b.com.br", :envio => "e"})
    @resposta = cobranca.submit!

Licença
-------

Copyright (c) 2011 Rainer Borene

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
