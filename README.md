# Pokédex - Atividade 12 (Provider na PokéBattle) 🎮🔥

Este repositório contém a continuação do aplicativo **Pokédex**, com a migração do estado da tela de batalha (`setState`) para o **Provider** com `ChangeNotifier`. O objetivo foi deixar o gerenciamento de estado totalmente desacoplado da árvore de widgets e otimizar as reconstruções de tela.

Aqui está o guia rápido passo a passo de tudo que foi feito, como rodar o projeto localmente, como subir para o Firebase Hosting e como sincronizar com o GitHub!

---

## 🛠️ O que foi feito nesta atividade?

1. **Adicionado o Provider:** Instalado o pacote `provider: ^6.1.0` nas dependências.
2. **Criação do `BattleProvider`:** Criado o gerenciador de estado (`lib/battle_provider.dart`) que controla HP, XP, nível, cores de HP dinâmicas e mensagens de status (como "HP crítico" ou "desmaiou").
3. **Componentização do `StatBar`:** Extraído o widget `_StatBar` da tela de Pokémon para seu próprio arquivo público (`lib/stat_bar.dart`).
4. **Refatoração do `BattlePanel`:** Migrado de `StatefulWidget` para `StatelessWidget`. Agora ele consome de forma reativa os dados do `BattleProvider` com `context.watch()` e dispara ações com `context.read()`.
5. **Reatividade Inteligente no `PokemonCard`:** O card do Pokémon agora consome apenas o **Nível** via `context.select()`, garantindo que ele só seja reconstruído quando o nível subir (evitando reconstruções desnecessárias a cada ataque/cura).
6. **Provider com escopo local:** Registrado o `ChangeNotifierProvider` dentro de `PokemonScreen` encapsulando apenas a tela de batalha.

---

## 🚀 Guia de Operações (Como rodar, subir e salvar)

### 1. Testar o App Localmente
Se você quiser rodar o aplicativo no navegador Chrome localmente:
```powershell
flutter run -d chrome
```

> 💡 **Nota sobre erros de segurança do Git:** 
> Se ao rodar o Flutter você receber o erro `"To add an exception for this directory, call: git config --global --add safe.directory C:/src/flutter"`, execute no seu terminal:
> ```powershell
> & "C:\Program Files\Git\cmd\git.exe" config --global --add safe.directory C:/src/flutter
> ```

---

### 2. Como Hospedar no Firebase Hosting (Deploy)

Para publicar o seu jogo na web de forma que qualquer pessoa possa jogar:

#### Passo A: Compilar o app para Web
```powershell
flutter build web
```
*(Esse comando vai gerar os arquivos estáticos prontos para a internet dentro da pasta `build/web`)*

#### Passo B: Inicializar o Firebase (Apenas na primeira vez)
Se você precisar reconfigurar o projeto:
```powershell
firebase.cmd init hosting
```
* **Use an existing project?** Sim (Selecione o seu projeto do Firebase).
* **Public directory:** Digite `starter-atividade-12/build/web` (ou `build/web` se você estiver dentro da pasta interna).
* **Single-page app?** Digite `y` (Sim).
* **GitHub builds/deploys?** Digite `n` (Não).
* **Overwrite index.html?** Digite `n` (Não).

#### Passo C: Publicar o site!
```powershell
firebase.cmd deploy
```
*O Firebase vai te devolver uma **Hosting URL** (ex: `https://atividade-6--pokedex.web.app`). Acesse ela no navegador e dê **Ctrl + F5** para limpar o cache se necessário!*

---

### 3. Como Enviar para o GitHub 🐙

Se você quer mandar todo o seu código-fonte para o seu repositório remoto:

```powershell
# 1. Inicializa o Git no diretório atual
& "C:\Program Files\Git\cmd\git.exe" init

# 2. Conecta ao seu repositório do GitHub
& "C:\Program Files\Git\cmd\git.exe" remote add origin https://github.com/VictorFP335/Pokedex.git

# 3. Define a branch principal como main
& "C:\Program Files\Git\cmd\git.exe" branch -M main

# 4. Adiciona todos os arquivos do projeto para serem salvos
& "C:\Program Files\Git\cmd\git.exe" add .

# 5. Salva suas alterações com uma mensagem descritiva
& "C:\Program Files\Git\cmd\git.exe" commit -m "Atividade 12 - Provider na PokéBattle"

# 6. Envia o código para o ar no GitHub (com força para atualizar tudo)
& "C:\Program Files\Git\cmd\git.exe" push -u origin main --force
```

---

## 📁 Estrutura Final do Projeto

```
lib/
├── main.dart
├── auth_screen.dart
├── home_screen.dart
├── pokemon.dart
├── pokemon_service.dart
├── pokemon_screen.dart          ← PokemonCard reativo, BattlePanel sem setState
├── stat_bar.dart                ← Nova (extraída de pokemon_screen)
├── battle_provider.dart         ← Nova (ChangeNotifier para estado de batalha)
├── new_pokemon_screen.dart
├── trainer_profile_screen.dart
├── location_service.dart
└── type_chip.dart
```

Feito com 💜 para facilitar o aprendizado e ensinar outras pessoas a gerenciarem estados com Provider no Flutter!
