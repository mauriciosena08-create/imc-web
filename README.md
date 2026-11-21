# IMC Web

O IMC Web é uma aplicação que recebe peso e altura, calcula o Índice de Massa Corporal e apresenta a classificação correspondente. A Parte I da atividade inclui a interface, a API e os testes automatizados. Na Parte II, a dupla vai executar a aplicação com Docker, configurar os testes no GitHub e publicar o projeto na Vercel.

## 1. Como executar o projeto em outro computador

Antes de começar, instale o Git e o Node.js 24 com npm. Para a etapa de contêineres no Windows, use o Docker Desktop com WSL 2.

Abra o terminal na pasta onde deseja guardar o projeto e execute um comando de cada vez:

```bash
git clone https://github.com/mauriciosena08-create/imc-web.git
cd imc-web
npm ci
npx playwright install chromium
npm start
```

Abra http://localhost:3000 no navegador. Digite **80** no campo de peso e **2** no campo de altura. O resultado esperado é **IMC 20,00 — Peso adequado**.

Para encerrar o servidor, volte ao terminal e pressione **Ctrl + C**.

## 2. Conferir os testes da Parte I

Dentro da pasta `imc-web`, execute:

```bash
npm run test:unit
npm run test:integration
npm run test:functional
npm run test:e2e
```

Os testes unitários verificam as regras de cálculo e classificação. Os de integração verificam as respostas da API. O teste funcional usa uma resposta simulada da API para verificar a interface. O teste de ponta a ponta percorre o fluxo completo pelo navegador usando a API real.

Confira se os quatro comandos terminam sem falhas antes de começar a Parte II.

## 3. Construir a imagem Docker

Esta etapa acompanha as seções 10 e 11 do PDF. Abra o Docker Desktop e aguarde a inicialização. No terminal, execute:

```bash
docker version
```

A saída deve mostrar `Client` e `Server`. Em seguida, crie os arquivos `.dockerignore` e `Dockerfile` na mesma pasta que o `package.json`. Copie para cada arquivo o bloco correspondente da seção 11 do PDF. O nome `Dockerfile` deve ficar sem extensão.

Construa a imagem da aplicação:

```bash
docker build -t imc-web:1 .
```

O ponto no final indica que o Docker deve usar os arquivos da pasta atual. Para construir especificamente a etapa de testes descrita no tutorial, execute:

```bash
docker build --target testes -t imc-web:testes .
```

## 4. Executar a aplicação no contêiner

Inicie o contêiner e confira os registros do servidor:

```bash
docker run --rm -d --name imc-lab -p 3001:3000 imc-web:1
docker ps
docker logs imc-lab
```

Abra http://localhost:3001 e repita o cálculo com **80 kg e 2 m**. Use a porta **3001** para acessar a versão do Docker. A porta **3000** no computador fica disponível para a versão iniciada com `npm start`.

Para fazer o experimento da seção 12, altere o título indicado em `public/index.html`, salve e recarregue a página na porta 3001. O título antigo continua aparecendo porque o contêiner está usando a cópia incluída na imagem. Reconstrua a imagem e inicie o contêiner novamente:

```bash
docker stop imc-lab
docker build -t imc-web:1 .
docker run --rm -d --name imc-lab -p 3001:3000 imc-web:1
```

Recarregue a página e confira o novo título. Ao terminar, encerre o contêiner com `docker stop imc-lab`.

## 5. Configurar os testes automáticos no GitHub

Sigam as seções 13 a 15 do PDF.

1. Confiram se a pessoa que vai enviar as alterações aceitou o convite de colaborador. Usem `git remote -v` para verificar se a pasta está conectada ao repositório `mauriciosena08-create/imc-web`.
2. Criem `.github/workflows/ci.yml` com o conteúdo indicado no tutorial. Enviem esse arquivo, o `Dockerfile` e o `.dockerignore` para o GitHub.
3. Na aba **Actions**, abram a execução e localizem o job `qualidade`. Confiram se os testes e a construção da imagem Docker passaram.
4. Depois que o check `qualidade` aparecer no GitHub, configurem a regra de proteção da `main` conforme o PDF. A regra deve estar ativa e exigir um pull request com esse check aprovado.
5. A partir desse ponto, trabalhem em branches e integrem as alterações por pull request.

## 6. Configurar a publicação na Vercel

Sigam as seções 16 e 17 do PDF.

1. Configurem o projeto na Vercel. No GitHub, abram **Settings → Secrets and variables → Actions** e cadastrem `VERCEL_TOKEN`, `VERCEL_ORG_ID` e `VERCEL_PROJECT_ID`. Os valores devem ficar nos secrets do repositório.
2. Adicionem o `vercel.json` da seção 16 por pull request. A configuração precisa chegar à `main` para desativar a publicação automática pela integração Git da Vercel.
3. Com os três secrets cadastrados, criem `.github/workflows/deploy.yml` conforme a seção 17. Abram o pull request e aguardem o check `qualidade` antes do merge.
4. Após o merge, abram **Actions** e confiram se o job de publicação executou depois dos testes. Acessem a URL de produção e façam um cálculo para confirmar que a API também funciona.

## 7. Registrar o incidente exigido pelo professor

Na seção 18, a dupla precisa demonstrar uma falha e sua correção **no mesmo pull request**. Comecem criando uma branch a partir da `main` atualizada:

```bash
git switch main
git pull --ff-only
git switch -c corrigir-limite-25
```

1. Em `src/imc.js`, façam a alteração indicada no PDF para que o valor 25 seja classificado incorretamente como “Peso adequado”. Em `tests/integration/api.test.js`, acrescentem o teste HTTP do limite 25. Preservem o teste unitário existente.
2. Executem os testes unitários e de integração, registrem as falhas e enviem a versão defeituosa para a branch.
3. Abram o pull request **Incidente: corrigir classificação no limite 25**. Antes de corrigir o código, capturem o check vermelho e a indicação de que o merge está bloqueado.
4. Na mesma branch, restaurem a comparação `imc < 25`, mantenham o novo teste e executem novamente os quatro grupos de testes. Façam commit e push da correção.
5. Registrem o check verde no mesmo pull request, concluam o merge e acompanhem o deploy na aba **Actions**.

## 8. Conferência e entrega

Na URL publicada, verifiquem os resultados:

| Peso | Altura | IMC esperado | Classificação |
|---|---|---|---|
| 80 kg | 2 m | 20,00 | Peso adequado |
| 100 kg | 2 m | 25,00 | Sobrepeso |
| 99,99 kg | 2 m | 25,00 após arredondamento | Sobrepeso |

Para a entrega, reúnam o **link do repositório**, o **link do pull request do incidente**, a **URL de produção** e as capturas pedidas no PDF, incluindo o bloqueio do merge e a aprovação após a correção.
