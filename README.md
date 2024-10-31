# Jogo da Forca em Assembly 🎮

Um jogo clássico da forca implementado em MIPS Assembly. Este projeto demonstra conceitos de programação em baixo nível enquanto oferece uma experiência de jogo divertida.

## Funcionalidades
- Visualização completa em arte ASCII do boneco da forca em diferentes estados
- Tratamento de entrada sem diferenciação de maiúsculas e minúsculas
- Validação de entrada para letras
- Rastreamento de letras já usadas
- Contador de vidas
- Opção de jogar novamente
- Funcionalidade de limpar tela para uma experiência de usuário melhor
- Interface em português

## Regras do Jogo
- Uma palavra secreta é inserida no início do jogo
- O jogador tem 6 vidas (tentativas) para adivinhar a palavra
- A cada erro, uma vida é perdida e o desenho do boneco avança
- Letras já adivinhadas não podem ser reutilizadas
- O jogo termina quando:
  - O jogador adivinha a palavra (VITÓRIA)
  - O jogador fica sem vidas (GAME OVER)

## Detalhes Técnicos

### Segmento de Dados
- Armazenamento dinâmico para a palavra secreta (20 bytes)
- Array para rastrear letras usadas (26 bytes, uma para cada letra)
- Buffer de exibição para mostrar o estado atual da palavra
- Arte ASCII para diferentes estados do boneco da forca
- Diversas mensagens e prompts do jogo

### Implementação das Principais Funcionalidades

#### Tratamento de Entrada
- Converte maiúsculas para minúsculas
- Valida entrada para garantir que apenas letras sejam aceitas
- Rastreamento de letras já usadas para evitar repetições

#### Sistema de Exibição
Exibe o estado atual do jogo, incluindo:
- Arte ASCII do boneco da forca
- Vidas restantes
- Letras já usadas
- Progresso atual da palavra

#### Funcionalidade de limpar tela para exibição limpa

#### Lógica do Jogo
- Verificação da condição de vitória
- Sistema de gerenciamento de vidas
- Funcionalidade de jogar novamente

## Como Executar
1. Carregue o programa em um simulador MIPS (ex: MARS, QtSpim)
2. Monte e execute o programa
3. Siga os prompts na tela:
   - Insira uma palavra secreta quando solicitado
   - Comece a adivinhar letras
   - Escolha jogar novamente ou sair quando o jogo acabar

## Controles
- Digite letras (a-z ou A-Z) para adivinhar
- `s` para jogar novamente após o fim do jogo
- `n` para sair após o fim do jogo

## Estrutura do Código 

### Rotinas Principais
- `main`: Ponto de entrada e inicialização do jogo
- `inicio_jogo`: Inicialização e configuração do jogo
- `game_loop`: Loop principal da lógica do jogo
- `perguntar_jogar_novamente`: Controle para jogar novamente

### Sub-rotinas
- `mostrar_estado`: Exibe o estado atual do jogo
- `verificar_vitoria`: Verifica a condição de vitória
- `validar_entrada`: Valida a entrada do usuário

## Notas
- A interface do jogo está em português
- O programa inclui tratamento extensivo de erros
- Utiliza syscalls para operações de entrada/saída
- Implementa manipulação de strings eficiente em memória

## Autores
Cassiano Menezes, Eduardo Vieira e Luiz Augusto Farias Hora

## Licença
Este projeto é licenciado sob a licença MIT - veja o arquivo [LICENSE] para mais detalhes.
