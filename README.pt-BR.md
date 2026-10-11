# es-theme-steamdeck

[EN](README.md) · **BR**

![Plataforma](https://img.shields.io/badge/Plataforma-EmulationStation-8A2BE2?style=flat-square) [![Licença](https://img.shields.io/badge/Licen%C3%A7a-CC_BY--NC_4.0-lightgrey?style=flat-square)](LICENSE) [![Reddit](https://img.shields.io/badge/Reddit-u%2Fjovemlcxx-FF4500?style=flat-square&logo=reddit&logoColor=white)](https://www.reddit.com/user/jovemlcxx/) [![Ko-fi](https://img.shields.io/badge/Ko--fi-Apoie-FF5E5B?style=flat-square&logo=ko-fi&logoColor=white)](https://ko-fi.com/jovemlcxx)

Tema no estilo do Steam Deck para o **EmulationStation-fcamod** no **R36S** e clones (família ArkOS, 640×480), com dois extras opcionais: **vídeo de boot** e **UI Fixes** (carrossel opaco e sons extras).

<p align="center">
  <img src="images/carousel-snes.jpg" width="49%"> <img src="images/carousel-ports.jpg" width="49%"><br>
  <img src="images/gamelist-zelda.jpg" width="49%"> <img src="images/gamelist-castlevania.jpg" width="49%">
</p>

[Instalação](#instalação) · [Tema](#o-tema) · [Vídeo de boot](#vídeo-de-boot) · [UI Fixes](#steam-deck-ui-fixes) · [Compatibilidade](#compatibilidade) · [Personalizar](#personalizar)

## Instalação

Baixe o zip do **seu** sistema na [página de Releases](https://github.com/jovemlcxx/es-theme-steamdeck/releases/latest):

| Seu sistema | Zip |
|---|---|
| ArkOS | `es-theme-steamdeck-ArkOS.zip` |
| arkos4clone | `es-theme-steamdeck-arkos4clone.zip` |
| dArkOS4Clone | `es-theme-steamdeck-dArkOS4Clone.zip` |
| dArkOS | `es-theme-steamdeck-dArkOS.zip` |
| dArkOSRE-R36 | `es-theme-steamdeck-dArkOSRE-R36.zip` |
| dArkOSen | `es-theme-steamdeck-dArkOSen.zip` |

Extraia e copie cada pasta para a partição do cartão SD de mesmo nome:

```
BOOT/                            -> partição de boot
├── boot.mp4                        vídeo de boot (não vem no zip do dArkOS: lá ele não funciona)
└── logo.bmp                        logo de boot
EASYROMS/                        -> partição de jogos (/roms)
├── themes/es-theme-steamdeck/      o tema
└── tools/                          os scripts deste sistema:
    ├── Enable / Disable Boot Video.sh
    ├── Enable Steam Deck UI Fixes (<sistema>).sh
    └── Disable Steam Deck UI Fixes.sh
```

1. **START → Configurações de interface → Tema → es-theme-steamdeck**. Escuro/claro fica no mesmo menu.
2. Opcional: rode os scripts em **Opções → Tools** (veja [Vídeo de boot](#vídeo-de-boot) e [UI Fixes](#steam-deck-ui-fixes)).

O repositório tem os mesmos arquivos descompactados (`BOOT/`, `EASYROMS/` com o que todos os sistemas compartilham, e `UI Fixes/<sistema>/` com o instalador de cada um). Os zips não são commitados: ficam na página de Releases, e `python src/make-zips.py` os refaz.

## O tema

- Uma **capa vertical de mesmo tamanho** por sistema (192×288, 2:3, como na biblioteca da Steam): screenshot do jogo mais conhecido da plataforma, a logo do próprio sistema e um contorno fino. 310 sistemas mais as 3 coleções têm uma. Os 21 sem screenshot em lugar nenhum (computadores obscuros e homebrew) usam o cartão cinza da Steam com a logo.
- A capa selecionada é o fundo da página, desfocada e se misturando à cor da página. A lista de jogos segue a página de jogo do Deck: imagem no topo, PLAY, última sessão, vezes jogado, lista e descrição.
- Esquemas escuro e claro. Por enquanto o tema é focado no **R36S, 4:3 (640×480)**; outras proporções de tela estão planejadas e chegam em breve.
- **27 idiomas** (os mesmos do tema XMB): rodapé, abas, rótulos, datas e o banner do PortMaster.
- Sons da interface do Steam Deck. A navegação toca em qualquer ES; select/back/launch/favorite precisam do UI Fixes.

<p align="center">
  <img src="images/carousel-mame.jpg" width="32%"> <img src="images/carousel-capcom.jpg" width="32%"> <img src="images/gamelist-gundam-w.jpg" width="32%">
</p>

## Vídeo de boot

`Enable Boot Video.sh` toca o `boot.mp4` (de `/boot` ou `/flash`) depois da logo de boot e antes do EmulationStation, e esconde os terminais do boot e o cursor de texto. `Disable Boot Video.sh` desfaz.

| Sistema | Método |
|---|---|
| ArkOS, arkos4clone, dArkOSen, dArkOSRE-R36 | serviço systemd `bootvideo.service`; o `boot.ini` recebe `vt.color=0x00 vt.global_cursor_default=0` (backup `boot.ini.bak-bootvideo`); a tela "Welcome to…" dos clones do lcdyk é pulada enquanto o vídeo existir. O `ffmpeg` decodifica direto para o `/dev/fb0` (sem janela, sem cursor do mouse), com `ffplay`/`mpv` de reserva |

O script também tem código para outros sistemas, mas só os da tabela de compatibilidade abaixo estão confirmados. Dica: 640×480, H.264, poucos segundos.

## Steam Deck UI Fixes

O ES dessa família desenha os itens não selecionados do carrossel com 50% de opacidade fixa e ignora a maioria dos sons do tema. O UI Fixes instala um EmulationStation com patch que acrescenta `unselectedOpacity` ao `<carousel>` (o tema usa `1`, então as capas ficam 100% opacas), toca os sons `select`, `back`, `favorite` e `quicksysselect`, **mantém o scraper do ScreenScraper** e mostra uma logo pequena na tela de carregamento. `Disable Steam Deck UI Fixes.sh` restaura o original (guardado como `emulationstation.orig-xmbsounds`).

*Estes extras são opcionais e reversíveis: fazem backup, podem ser desfeitos a qualquer momento com `Disable Steam Deck UI Fixes.sh`, e cada build só roda no sistema para o qual foi feito. O tema funciona bem sem eles — use se quiser o acabamento extra, por sua escolha.*

**Um instalador por sistema.** Cada distro do R36S embarca o *seu próprio* EmulationStation (menus, Wi-Fi e hardware diferentes), então há um build para cada, feito da fonte do ES daquela distro, mudando só as duas coisas acima — nada mais. O zip do seu sistema já traz o instalador certo em `EASYROMS/tools`: rode **Enable Steam Deck UI Fixes (seu sistema)** em **Opções → Tools**.

Cada instalador confere o EmulationStation que já está no aparelho e **se recusa a rodar se não for o que ele espera**, então rodar o arquivo errado não altera nada. Também confere a arquitetura e as bibliotecas antes. Uma atualização do sistema que troque o ES desfaz o fix — é só rodar o instalador de novo.

<details><summary>Compilar do código-fonte</summary>

Fontes (`src/ui-fixes` tem os dois patches + `build.sh`/`pack.sh`). Cada sistema é compilado do seu próprio fork do ES, num container Docker Debian 10 arm64 (glibc antiga):

| Sistema | Fonte do ES |
|---|---|
| arkos4clone | [lcdyk0517/EmulationStation-fcamod](https://github.com/lcdyk0517/EmulationStation-fcamod) `dev` |
| dArkOS, dArkOSRE, ArkOS | [christianhaitian/EmulationStation-fcamod](https://github.com/christianhaitian/EmulationStation-fcamod) `503noTTS` |
| dArkOSen | [djparentx/EmulationStation-fcamod-dArkOS-EN](https://github.com/djparentx/EmulationStation-fcamod-dArkOS-EN) |

Cada sistema tem um `src/ui-fixes/systems/<sistema>/system.env` (`arkos`, `arkos4clone`, `darkos`, `darkosre`, `darkosen`) com o nome e as strings da trava. Clone a fonte do ES dentro de `src/`, depois compile e empacote, por exemplo para o dArkOS:

```bash
git clone --recursive -b 503noTTS https://github.com/christianhaitian/EmulationStation-fcamod.git src/EmulationStation-fcamod-chmod
bash src/ui-fixes/build.sh EmulationStation-fcamod-chmod darkos   # aplica os dois patches, compila (~10-15 min)
bash src/ui-fixes/pack.sh darkos                                  # -> src/tools/Enable Steam Deck UI Fixes (dArkOS).sh
```
As credenciais do scraper (opcional) vão em `src/ui-fixes/scraper.env`. Fontes, binários e credenciais são ignorados pelo git.
</details>

## Compatibilidade

O que foi realmente testado, e como:

| | Tema | Vídeo de boot | UI Fixes |
|---|---|---|---|
| dArkOS4Clone | ✅ | ✅ | ✅ |
| dArkOSen | ✅ | ✅ | ✅ |
| ArkOS | ☑️ | ☑️ | 🧪 |
| dArkOS | ☑️ | ❌ não funciona | 🧪 |
| arkos4clone | ☑️ | ☑️ | 🧪 |
| dArkOSRE-R36 | ☑️ | ☑️ | 🧪 |
| muOS | ❌ não funciona | – | – |
| ArchR, Batocera, Knulli, EmuELEC | ainda não testado | ainda não testado | ainda não testado |

- ✅ **Validado em aparelho real** com a versão atual: tema, vídeo de boot, o instalador do UI Fixes (menus intactos, cápsulas opacas, scraper) e o Disable.
- ☑️ **Relatado como funcionando por testadores** em uma versão anterior. Não foi testado de novo na atual.
- 🧪 **Construído e conferido offline, aguardando retorno.** O instalador desse sistema existe e passou nas verificações abaixo, mas ainda não foi executado nele. O build único anterior do UI Fixes foi relatado funcionando no ArkOS e no dArkOS; este é um build novo, por sistema.

<details><summary>O que foi conferido offline nos builds 🧪</summary>

- Cada instalador carrega exatamente o build feito do código do ES da própria distro (conferido por hash), com o scraper do ScreenScraper compilado.
- A trava de cada instalador aceita só o ES da própria família e recusa os outros (testado contra o ES publicado do dArkOSRE-R36, dArkOS-G80CA-RE, dArkOSen e arkos4clone).
- Os binários exigem GLIBC 2.17 ou anterior, e o instalador confere a arquitetura e as bibliotecas no aparelho antes de alterar qualquer coisa.
- ArkOS, dArkOS e dArkOSRE-R36 compartilham o mesmo build de ES (christianhaitian `503noTTS`). A correspondência do ArkOS é a melhor possível: se o seu ArkOS tem outro ES, o instalador recusa e não altera nada.
</details>

Outros limites: só 640×480 (4:3) por enquanto, outras proporções chegam em breve; abas, pílula STEAM e banner são decorativos; algumas screenshots são fracas (Lynx, Kodi); o esquema claro foi menos testado que o escuro.

### Ajude a testar o seu sistema

Se você usa um dos sistemas 🧪, rodar o instalador do seu sistema **é** o teste. Se algo parecer errado, rode o **Disable Steam Deck UI Fixes** primeiro: ele restaura o EmulationStation original.

**O que me contar**

1. Sistema, versão e modelo do aparelho.
2. Se o `Enable Steam Deck UI Fixes (<seu sistema>)` rodou ou recusou (copie a mensagem que ele mostra).
3. Depois dele: Wi-Fi, Bluetooth e os outros menus continuam lá? As cápsulas ficaram opacas? **SCRAPER → SCRAPE NOW** roda sem reiniciar o EmulationStation?
4. Se o `Disable Steam Deck UI Fixes` traz o original de volta.

**Onde enviar** (qualquer um dos dois serve)

- 💬 **[Abra uma issue](https://github.com/jovemlcxx/es-theme-steamdeck/issues)** neste repositório: fica pública, então outros usuários do mesmo sistema podem ver.
- 📩 **[Me mande uma mensagem no Reddit](https://www.reddit.com/user/jovemlcxx/)** (u/jovemlcxx): privado, se preferir.

## Personalizar

Os arquivos têm o nome da entrada `<theme>` do sistema no `es_systems.cfg` (ex.: `snes`, `megadrive`), não o da pasta de ROMs. Todos os caminhos ficam dentro de `_inc/`.

| O quê | Onde | Tamanho |
|---|---|---|
| Capa | `systems/capsule/<theme>.png` | 192×288 (2:3, maior também serve) |
| Fundo da lista de jogos (escuro / claro) | `systems/gl/` · `gl-light/` | 640×480 |
| Parte sob a imagem do jogo | `systems/glinfo/` · `glinfo-light/` | 640×284 |
| Banner (todos os sistemas, por idioma) | `images/banner-portmaster[-<lang>].png` | 1202×274 |
| Banner (um sistema) | `systems/banner/<theme>.png` | 1202×274 |
| Avatar | `images/avatar.png` | 96×96 |
| Cores | `colors/dark.xml`, `light.xml` | |
| Traduções | `lang/<code>.xml` | |

Para trocar uma capa cinza, coloque seu PNG com o nome do sistema em `systems/capsule/`. O layout está em `aspect-ratio-4-3.xml`; os textos em inglês são as `variables` no início do `theme.xml` (o fcamod para de ler blocos `variables` no primeiro de outro idioma, por isso cada tradução é um arquivo próprio).

## Créditos e licença

**Testes:** um agradecimento enorme à [Sabrina Broch](https://www.youtube.com/@sabrinabroch1/videos), querida YouTuber da comunidade brasileira de R36S, que testou com todo carinho o tema, o vídeo de boot e o primeiro build do UI Fixes em vários sistemas. Sem a ajuda dela este projeto não estaria confirmado em tantos sistemas. Conheça o canal dela!

**Licença:** [CC BY-NC 4.0](LICENSE)

**Apoie:** se este tema te for útil, você pode apoiar meu trabalho no [Ko-fi](https://ko-fi.com/jovemlcxx). Obrigado! ☕

[![Ko-fi](https://img.shields.io/badge/Apoie_no-Ko--fi-FF5E5B?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/jovemlcxx)
