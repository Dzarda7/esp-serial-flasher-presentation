---
theme: default
favicon: '/favicons/favicon-32x32.png'
colorSchema: dark
aspectRatio: 16/9
canvasWidth: 980
title: ESP-Serial-Flasher
info: |
  ## ESP-Serial-Flasher
  esptool pro embedded – flashování ESP čipů z jiných mikrokontrolérů, Androidu i Arduina.
class: text-center
drawings:
  persist: false
transition: slide-left
mdc: true
---

# ESP-Serial-Flasher

<span style="font-size: 2rem;">esptool, který se vejde do mikrokontroléru</span>

<div style="position: absolute; bottom: 2rem; left: 0; width: 100%; text-align: center;">
  Jaroslav Burian
</div>

<!--
Úvodní slide. Navazuje na ESP USB Bridge talk, který končil "příště esp-serial-flasher spin-off".
-->

---
layout: center
---

<div class="text-center text-4xl leading-relaxed">
  Minule na ESP USB Bridge… 📺<br>
  <span class="opacity-60 text-2xl">„Konec první kapitoly, příště esp-serial-flasher spin-off“</span><br><br>
  Kapitola druhá 🎬
</div>

<!--
Krátký callback na minulý talk. Pokud někdo minule nebyl, nevadí – navazovat se nebude.
-->

---

# Jak se ESP vlastně flashuje?

- 🧠 Každý ESP čip má v ROM bootloader, ten se nedá rozbít
- 🗣️ esptool, esptool-js, Arduino IDE, ESP-IDF… všichni mluví s ROM
- 🔌 Cesty k čipu:
  - UART + BOOT a RESET pin
  - USB-Serial-JTAG / USB CDC
  - SPI a SDIO (nahrání do RAM)

<!--
Záměrně bez detailů protokolu (SLIP, sync…). Pointa: komunikace s ROM bootloaderem je známá a stabilní,
takže ji může dělat kdokoliv, nejen Python na PC.
-->

---
transition: slide-up
---

# A co když po ruce není PC? 🤷

- 🐍 esptool = Python + počítač
- 🏭 Ve výrobě nechcete u každé linky notebook
- 📦 V produktu už je jiný procesor – proč nepoužít ten?
- 📱 Technik v terénu má v kapse jen telefon

---

# ESP-Serial-Flasher

### esptool napsaný v C pro embedded

- 🔗 Připojení, autodetekce čipu, MAC adresa, security info
- 💾 Zápis, čtení, mazání flash, ověření přes MD5
- 🧮 Nahrání a spuštění kódu v RAM
- 🔧 Registry, změna baudrate, reset cíle
- 🔓 Open source, Apache 2.0

---

# Kde se to hodí? 💡

<div class="grid grid-cols-2 gap-x-8 gap-y-3 mt-6 text-left">

<div>📡 <b>ESP jako Wi-Fi/BLE koprocesor</b><br><span class="opacity-70 text-sm">STM32/nRF aktualizuje ESP-Hosted nebo AT firmware v terénu</span></div>

<div>🏭 <b>Výroba a programování</b><br><span class="opacity-70 text-sm">Samostatná programovačka bez PC, víc kusů najednou</span></div>

<div>📱 <b>Servis v terénu</b><br><span class="opacity-70 text-sm">Update z telefonu přes USB OTG</span></div>

<div>🧩 <b>Víc ESP v jednom produktu</b><br><span class="opacity-70 text-sm">Hlavní ESP aktualizuje ostatní na desce</span></div>

<div>🧪 <b>Testovací přípravky</b><br><span class="opacity-70 text-sm">Nahrát test firmware do RAM, otestovat, nahrát produkční</span></div>

<div>🌐 <b>Gateway a hub</b><br><span class="opacity-70 text-sm">Brána aktualizuje připojené moduly po UART/CAN/RS-485</span></div>

<div>🚑 <b>Recovery</b><br><span class="opacity-70 text-sm">Oživení zařízení se zničenou aplikací – ROM přežije všechno</span></div>

<div>🎓 <b>Výuka a kity</b><br><span class="opacity-70 text-sm">Kit, který si sám nahraje úlohy do žákovských desek</span></div>

</div>

---

# Kdo flashuje a koho

<div class="grid grid-cols-2 gap-8 mt-6 text-left">
<div>

### 🖥️ Host

- ESP32 (UART, USB CDC, SPI, SDIO)
- STM32
- Raspberry Pi Pico / Pico 2
- Zephyr
- Linux (PC, Raspberry Pi…)
- 🆕 Arduino
- 🆕 Android

</div>
<div>

### 🎯 Cíl

- ESP8266
- ESP32, S2, S3
- C2, C3, C5, C6, C61
- H2, H21, H4
- P4, S31

<span class="opacity-70 text-sm">UART všude, USB CDC, SPI a SDIO podle čipu</span>

</div>
</div>

---

# Port = pár funkcí 🧩

```c {all|3-4|5-6|7-8|all}
const esp_loader_port_ops_t arduino_port_ops = {
    .init                     = arduino_init,
    .enter_bootloader         = arduino_enter_bootloader,  // BOOT + RESET
    .reset_target             = arduino_reset_target,
    .start_timer              = arduino_start_timer,
    .remaining_time           = arduino_remaining_time,
    .write                    = arduino_write,             // UART TX
    .read                     = arduino_read,              // UART RX
    .delay_ms                 = arduino_delay_ms,
    .change_transmission_rate = arduino_change_rate,
    .log                      = arduino_log,               // volitelné
};
```

- 📏 Arduino port ≈ 200 řádků, Android port ≈ 250 řádků
- 🧱 Zbytek (protokol, stub, eFuse…) je společný

<!--
Tohle je skutečný port z Arduino knihovny (zkrácený o NULL položky pro SPI/SDIO).
Pointa: nová platforma = UART read/write, dva GPIO a časovač.
-->

---

# Použití

```c
esp_loader_t loader;
esp_loader_init_serial(&loader, &port.port);

esp_loader_connect_args_t args = ESP_LOADER_CONNECT_DEFAULT();
esp_loader_connect_with_stub(&loader, &args);

esp_loader_flash_cfg_t cfg = { .offset = 0x10000, .image_size = size, .block_size = 4096 };
esp_loader_flash_start(&loader, &cfg);
while (/* data */) {
    esp_loader_flash_write(&loader, &cfg, chunk, chunk_len);
}
esp_loader_flash_finish(&loader, &cfg);   // ověří MD5
```

<!--
Pro hobbisty: připojit, nahrát, hotovo. Odkud data přijdou (SD karta, Wi-Fi, LittleFS, pole v C) je na vás.
-->

---

# Co je nového? 🆕

<div class="grid grid-cols-2 gap-6 mt-6 text-left">

<div v-click>

### 🔐 eFuse API
Čtení MAC a security info, zápis eFuse a klíčů přímo z hosta

</div>

<div v-click>

### 🚀 Nový stub
esp-flasher-stub: vyšší baudrate, flash > 2 MB, komprese, rychlé čtení

</div>

<div v-click>

### 🔌 Rozhraní a čipy
USB CDC ACM, SPI/SDIO do RAM, ESP32-C5, C61, H21, H4, P4, S31

</div>

<div v-click>

### 🪶 Platíte jen za to, co používáte
Bez stubu, jen jeden stub, nebo stub z externí paměti. eFuse tabulky jen pro vaše čipy

</div>

</div>

---

# esptool-js 🤝 esp-serial-flasher

- 🌐 esptool-js plánuje stavět na esp-serial-flasher
- 🧠 Jedno jádro pro mikrokontroléry i prohlížeč
- 🐛 Opravené jednou = opravené všude

<!--
TODO: ověřit, co přesně můžu o plánech esptool-js veřejně říct (WebAssembly? časový plán?).
-->

---
layout: center
---

<div class="text-center">
  <h1 class="text-8xl">Demo time 🎬</h1>
</div>

---
layout: two-cols
class: text-left
---

# 📱 Flashování z telefonu

- 🤖 Nativní Android aplikace (Kotlin + Compose)
- 🔗 esp-serial-flasher přes JNI, vlastní `android_port.c`
- 🔌 USB OTG: CP210x i USB-Serial-JTAG
- 🧳 Celá „programovačka“ v kapse

::right::

<div class="h-110">
  <PhoneMirror />
</div>

<!--
Demo: telefon zrcadlený přes scrcpy (./phone.sh) do v4l2loopback kamery, ESP32-C5 přes OTG.
Záloha: video/repozitář, pokud by scrcpy nebo OTG zlobilo.
-->

---

# 🔵 Arduino

- 📚 `EspSerialFlasher` v Arduino Library Manageru
- 🔁 Upstream kopírovaný 1:1, vlastní je jen port
- 📁 Příklad: nahraj `app.bin` z LittleFS do jiného ESP

```cpp
#include <EspSerialFlasher.h>

static ArduinoFlasherPort port;
static esp_loader_t loader;
```

<!--
TODO: video / screenshot z Arduino IDE (Library Manager → instalace → flash).
-->

---

# 🦠 Řetězový flasher

### ESP, které nakazí souseda

<div class="flex items-center justify-center gap-4 mt-10 text-xl">
  <div class="border-2 border-blue-400 rounded-lg px-5 py-4">ESP A</div>
  <div v-click class="flex items-center gap-4">➡️ <div class="border-2 border-blue-400 rounded-lg px-5 py-4">ESP B</div></div>
  <div v-click class="flex items-center gap-4">➡️ <div class="border-2 border-blue-400 rounded-lg px-5 py-4">ESP C</div></div>
  <div v-click class="flex items-center gap-4">➡️ <div class="border-2 border-blue-400 rounded-lg px-5 py-4">…</div></div>
</div>

<div class="mt-10">

- 🧬 Každá deska nahraje svůj firmware do další
- 🔌 USB host → USB-UART souseda → ROM bootloader

</div>

<!--
TODO: video dema. Aktuálně link test na ESP32-S3-LCD-EV-Board (~/Documents/My/flasher_chain).
-->

---

# ⚡ Paralelní flasher

### Jeden host, N cílů najednou

<div class="flex items-center justify-center gap-10 mt-8 text-xl">
  <div class="border-2 border-green-400 rounded-lg px-6 py-8">ESP32-P4</div>
  <div class="flex flex-col gap-2">
    <div>UART0 ➡️ <span class="border border-blue-400 rounded px-3 py-1">ESP #1</span></div>
    <div>UART1 ➡️ <span class="border border-blue-400 rounded px-3 py-1">ESP #2</span></div>
    <div>UART2 ➡️ <span class="border border-blue-400 rounded px-3 py-1">ESP #3</span></div>
    <div>UART… ➡️ <span class="border border-blue-400 rounded px-3 py-1">ESP #N</span></div>
  </div>
</div>

<div class="mt-8">

- 🏭 Výrobní linka bez PC
- 🧵 Každý cíl má vlastní `esp_loader_t`, takže běží nezávisle

</div>

<!--
TODO: video / počet desek / čas flashování vs. sériově.
-->

---

# Vyzkoušejte to! 🙌

- ⭐ GitHub: `github.com/espressif/esp-serial-flasher`
- 📦 ESP Component Registry: `espressif/esp-serial-flasher`
- 🔵 Arduino Library Manager: `EspSerialFlasher`
- 🐛 Issues a PR vítány, hlavně nové porty!

---

<div class="flex items-center justify-center h-full">
  <div class="text-center text-4xl">
  Díky! 🙏<br><br>Otázky?
  </div>
</div>
