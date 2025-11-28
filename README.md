📱 Finanças+ — Aplicativo de Controle Financeiro

O Finanças+ é um aplicativo mobile desenvolvido em Flutter/Dart com o objetivo de oferecer ao usuário uma forma simples, rápida e eficiente de registrar receitas, despesas e acompanhar sua vida financeira por meio de resumos mensais e gráficos analíticos.

🚀 Tecnologias Utilizadas
Tecnologia/Pacote	Função
Flutter/Dart	Framework principal para construção do aplicativo mobile.
sqflite	Persistência local de dados (SQLite).
fl_chart	Criação de gráficos de barras para análise visual.
intl	Formatação de moeda, datas e localização pt_BR.

📂 Arquitetura
O projeto segue uma arquitetura simples e organizada:
/lib
  /screens     -> Telas do aplicativo
  /models      -> Modelos de dados
  /helpers     -> Classes utilitárias (ex: DBHelper)

🧾 Modelo de Dados — TransactionModel
Cada transação registrada no app segue esta estrutura:
Campo	Tipo	Descrição
id	int	Identificador único.
title	String	Descrição da transação.
amount	double	Valor da transação.
type	String	Tipo: 'receita' ou 'despesa'.
date	DateTime	Data da transação (indispensável para resumos e gráficos).

🗄️ Persistência de Dados
A classe DBHelper gerencia todo o acesso ao SQLite:
Criação do banco e tabela transactions
Métodos CRUD:
insertTransaction()
getTransactions()
updateTransaction()
deleteTransaction()
A coluna date TEXT armazena as datas em formato ISO8601.

🧭 Funcionalidades do Aplicativo
🔐 1. Tela de Login
Login de demonstração usando:
E-mail: teste@teste.com
Senha: 1234

💰 2. Tela de Transações
Cards com saldo e despesas do mês
Lista mostrando somente o mês atual
CRUD completo
Modal com seletor de data

📊 3. Tela de Resumo
Total de Entradas
Total de Despesas
Saldo do mês
Métricas de gasto

📈 4. Tela de Gráficos
Gráfico de despesas dos últimos 3 meses
Sugestões de análise
