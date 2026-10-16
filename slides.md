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
  Minule na ESP USB Bridge…<br>
  <span class="opacity-60 text-2xl">„Konec první kapitoly, příště esp-serial-flasher spin-off“</span><br><br>
  Kapitola druhá 🎬
</div>

<!--
Krátký callback na minulý talk. Pokud někdo minule nebyl, nevadí – navazovat se nebude.
-->

---

# Jak se ESP vlastně flashuje?

- 🧠 Každý ESP čip má v ROM bootloader, ten se nedá rozbít
- 🗣️ Všechny flashovací nástroje mluví se stejnou ROM
- 📜 Protokol je veřejně zdokumentovaný a napříč čipy skoro stejný → může jím komunikovat každý

<div class="flex items-center justify-center mt-8">
  <div class="flex flex-col gap-2">
    <div class="border border-gray-500 rounded-md px-3 text-right" style="height:32px;line-height:30px">esptool</div>
    <div class="border border-gray-500 rounded-md px-3 text-right" style="height:32px;line-height:30px">esptool-js</div>
    <div class="border border-gray-500 rounded-md px-3 text-right" style="height:32px;line-height:30px">espflash</div>
    <div class="border border-gray-500 rounded-md px-3 text-right" style="height:32px;line-height:30px">Arduino IDE</div>
    <div class="border border-gray-500 rounded-md px-3 text-right" style="height:32px;line-height:30px">ESP-IDF</div>
  </div>
  <div class="relative">
  <div class="absolute text-sm opacity-60" style="left:130px;top:72px">UART / USB</div>
  <svg width="260" height="200" viewBox="0 0 260 200">
    <defs><marker id="arr" markerUnits="userSpaceOnUse" markerWidth="12" markerHeight="12" refX="10" refY="6" orient="auto"><path d="M0,0 L12,6 L0,12 z" fill="#60a5fa"/></marker></defs>
    <line x1="0" y1="20" x2="120" y2="100" stroke="#60a5fa" stroke-width="2"/>
    <line x1="0" y1="60" x2="120" y2="100" stroke="#60a5fa" stroke-width="2"/>
    <line x1="0" y1="100" x2="120" y2="100" stroke="#60a5fa" stroke-width="2"/>
    <line x1="0" y1="140" x2="120" y2="100" stroke="#60a5fa" stroke-width="2"/>
    <line x1="0" y1="180" x2="120" y2="100" stroke="#60a5fa" stroke-width="2"/>
    <line x1="120" y1="100" x2="250" y2="100" stroke="#60a5fa" stroke-width="3" marker-end="url(#arr)"/>
  </svg>
  </div>
  <div class="border-2 border-blue-400 rounded-xl px-6 py-5 text-xl">🧠 ROM bootloader</div>
</div>

<div class="mt-6 text-sm opacity-70">📖 <a href="https://docs.espressif.com/projects/esptool/en/latest/esp32/advanced-topics/serial-protocol.html">esptool docs → Serial Protocol</a></div>

<!--
Záměrně bez detailů protokolu (SLIP, pakety…). Pointa: komunikace s ROM bootloaderem je známá a stabilní,
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

<div class="mt-10 text-3xl leading-relaxed">
esptool jako C knihovna<br>
<span class="opacity-80">snadno portovatelná na jakoukoliv platformu</span>
</div>

<div class="grid grid-cols-3 gap-6 mt-14 text-center">
  <div>🧩<br><b>Čisté C</b><br><span class="opacity-70 text-sm">bez závislostí a bez malloc</span></div>
  <div>🔌<br><b>Port = pár funkcí</b><br><span class="opacity-70 text-sm">UART, dva piny, časovač</span></div>
  <div>🔓<br><b>Open source</b><br><span class="opacity-70 text-sm">Apache 2.0</span></div>
</div>

---

# Co umí? 🧰

<div class="grid grid-cols-2 gap-x-8 mt-6 text-left">
<div>

- 🔗 Připojení, autodetekce čipu, MAC, security info
- 💾 Flash: zápis, čtení, mazání, ověření MD5
- 🗜️ Komprimovaný zápis (deflate)
- 🧮 Nahrání a spuštění kódu v RAM

</div>
<div>

- 🚀 Flasher stub: rychlejší, vyšší baudrate
- 🔐 eFuse: čtení, zápis eFuse a klíčů
- 🔧 Registry, změna baudrate, reset čipu
- 🧳 Víc čipů najednou, každý se svým stavem

</div>
</div>

---

# Rozhraní: jak se připojit k čipu 🔌

<div class="grid grid-cols-2 gap-4 mt-4 text-left">

<div class="border border-gray-600 rounded-lg px-4 py-2">
<b>🧵 UART</b> <span class="opacity-70 text-sm">+ BOOT a RESET pin</span><br>
<span class="text-sm">Všechno umí, všechny čipy od ESP8266 po S31</span>
</div>

<div class="border border-gray-600 rounded-lg px-4 py-2">
<b>🔌 USB</b> <span class="opacity-70 text-sm">bez převodníku, rovnou do čipu</span><br>
<span class="text-sm"><b>USB-Serial-JTAG:</b> S3, C3, C5, C6, C61, H2, H21, H4, P4, S31<br><b>USB-OTG (CDC):</b> S2, S3, P4</span>
</div>

<div class="border border-gray-600 rounded-lg px-4 py-2">
<b>⚡ SPI</b> <span class="opacity-70 text-sm">zatím jen nahrání do RAM</span><br>
<span class="text-sm">Flashování přijde 🔜<br>S3, C2, C3, H2</span>
</div>

<div class="border border-gray-600 rounded-lg px-4 py-2">
<b>💾 SDIO</b><br>
<span class="text-sm">C5, C6</span>
</div>

</div>

<div class="mt-6 text-left">

🖥️ <b>Porty v knihovně:</b> ESP32, STM32, Raspberry Pi Pico, Zephyr, Linux, <span class="opacity-70 whitespace-nowrap">🚧 esptool-js</span>

</div>

<!--
Podle README esp-serial-flasher (USB-Serial-JTAG) a esptoolu (USB-OTG: S2, S3, P4 – v README ESF zatím chybí, ale funguje). Ve vývoji: SPI pro H21, P4, H4; SDIO pro ESP32 a C61.
USB CDC na straně hostitele = ESP32-S3/P4 jako USB host (paralelní demo, Android).
-->

---

# Port = pár funkcí 🧩

```c {all|2-3|4-5|6-8|9-11|all}
typedef struct {
    esp_loader_error_t (*init)(esp_loader_port_t *port);         // volitelné
    void (*deinit)(esp_loader_port_t *port);                     // volitelné
    void (*enter_bootloader)(esp_loader_port_t *port);           // BOOT + RESET
    void (*reset_target)(esp_loader_port_t *port);
    void     (*start_timer)(esp_loader_port_t *port, uint32_t ms);
    uint32_t (*remaining_time)(esp_loader_port_t *port);
    void     (*delay_ms)(esp_loader_port_t *port, uint32_t ms);
    esp_loader_error_t (*write)(esp_loader_port_t *port, const uint8_t *data, …);
    esp_loader_error_t (*read)(esp_loader_port_t *port, uint8_t *data, …);
    esp_loader_error_t (*change_transmission_rate)(esp_loader_port_t *port, uint32_t rate);
    void (*log)(…);                                              // volitelné
    // + spi_set_cs, sdio_read/write/card_init pro SPI a SDIO
} esp_loader_port_ops_t;
```

- 📏 Arduino port ≈ 200 řádků, Android port ≈ 250 řádků
- 🧱 Zbytek (protokol, stub, eFuse…) je společný

<!--
Skutečná struktura z include/esp_loader_io.h, zkrácené jen parametry a komentáře.
Pointa: nová platforma = UART read/write, dva GPIO a časovač.
-->

---

# Použití: port + knihovna

```c {1-7|8-9|11-12|14-18|all}
esp32_port_t port = {
    .port.ops    = &esp32_uart_ops,
    .baud_rate   = 115200,
    .uart_port   = UART_NUM_1,
    .uart_rx_pin = GPIO_NUM_5,  .uart_tx_pin = GPIO_NUM_4,
    .reset_pin   = GPIO_NUM_25, .boot_pin    = GPIO_NUM_26,
};
esp_loader_t loader;                                  // stav čipu: typ, stub, flash…
esp_loader_init_serial(&loader, &port.port);

esp_loader_connect_args_t args = ESP_LOADER_CONNECT_DEFAULT();
esp_loader_connect_with_stub(&loader, &args);

esp_loader_flash_cfg_t cfg = { .offset = 0x10000, .image_size = size, .block_size = 4096 };
esp_loader_flash_start(&loader, &cfg);
while (/* data */)
    esp_loader_flash_write(&loader, &cfg, chunk, chunk_len);
esp_loader_flash_finish(&loader, &cfg);               // ověří MD5
```

<div class="mt-3">🧳 Žádné globály: další čip = další port + další <code>esp_loader_t</code> → paralelní flashování</div>

<!--
Port pro ESP32 je přímo v knihovně (port/esp32_port.h). Odkud data přijdou (SD karta, Wi-Fi, LittleFS, pole v C) je na vás.
Paralelní demo: 8 čipů = 8 portů + 8 loaderů, každý ve vlastním tasku.
-->

---

# Kolik to stojí? 🪶

<div class="text-sm opacity-70 mt-1">Jen knihovna (bez portu a libc) · connect + flash + MD5 · <code>-Os</code>, <code>--gc-sections</code>, logování vypnuté</div>

<table class="mt-6 text-lg">
<thead><tr><th class="text-left">Varianta</th><th class="!text-right">Flash</th><th></th></tr></thead>
<tbody>
<tr><td>Jen ROM, bez stubu</td><td class="text-right">~8 kB</td><td><div class="h-3 rounded bg-green-500" style="width:8px"></div></td></tr>
<tr><td>Všechny stuby (<code>connect_with_stub</code>)</td><td class="text-right">~120 kB</td><td><div class="h-3 rounded bg-red-500" style="width:240px"></div></td></tr>
<tr><td>Jeden stub (<code>stub_provider</code>)</td><td class="text-right">~17 kB</td><td><div class="h-3 rounded bg-yellow-500" style="width:36px"></div></td></tr>
</tbody>
</table>

<div class="mt-4">💾 0 B statické RAM · stub jde nahrát i z externí paměti</div>

<!--
Měřeno na master (7d89055), RISC-V = esp toolchain GCC 16.1 rv32imc, Cortex-M4 = arm-none-eabi 13.2. Počítají se jen objekty knihovny.
Log NONE, RISC-V: 7 879 B / 123 443 B / 17 687 B. S logem WARN o ~0,9 kB víc. MD5 je zhruba třetina (2,6 kB).
-->

---
layout: center
---

<div class="text-center">
  <h1 class="text-7xl">Co se s tím dá postavit? 🛠️</h1>
</div>

---

# 🔵 Arduino

<div class="grid grid-cols-[1.1fr_1fr] gap-6 mt-4 items-start">

<img src="/images/arduino-readme.png" class="w-full rounded-lg border border-gray-700 shadow-lg" />

<div>

```cpp
#include <EspSerialFlasher.h>

ArduinoFlasherPort port;
esp_loader_t loader;

void setup() {
  Serial1.begin(115200, SERIAL_8N1, RX, TX);
  port.serial    = &Serial1;
  port.reset_pin = TARGET_EN;
  port.boot_pin  = TARGET_BOOT;

  esp_loader_init_serial(&loader, &port.port);
  esp_loader_connect_args_t args =
      ESP_LOADER_CONNECT_DEFAULT();
  esp_loader_connect_with_stub(&loader, &args);
  // … flash_start / write / finish
}
```

</div>
</div>

<div class="mt-4">📚 Arduino Library Manager: <code>EspSerialFlasher</code> · 🔗 <a href="https://github.com/Dzarda7/EspSerialFlasher">github.com/Dzarda7/EspSerialFlasher</a></div>

<!--
Obrázek = začátek README knihovny. Celý sketch: File → Examples → EspSerialFlasher → FlashFromFile (app.bin z LittleFS).
Upstream esp-serial-flasher je v knihovně 1:1, vlastní je jen Arduino port (~200 řádků).
-->

---
class: text-left
---

<div class="absolute right-6 top-16 bottom-3 w-72">
  <SlidevVideo autoplay autoreset="slide" loop muted playsinline class="h-full mx-auto rounded-xl shadow-lg">
    <source src="/videos/android-demo.mp4" type="video/mp4" />
  </SlidevVideo>
</div>

<div class="mr-76">

# 📱 Flashování z telefonu

- 🤖 Nativní Android aplikace (Kotlin + Compose)
- 🔗 esp-serial-flasher přes JNI, vlastní `android_port.c`
- 🔌 USB OTG: CP210x i USB-Serial-JTAG
- 🧳 Celá „programovačka“ v kapse

🔗 [github.com/Dzarda7/esp-flasher-android](https://github.com/Dzarda7/esp-flasher-android)

</div>

<!--
Demo: záznam z telefonu (scrcpy --record), ESP32-C5 přes OTG.
-->

---

# ⚡ Paralelní flasher

<SlidevVideo autoplay autoreset="slide" loop muted playsinline class="h-100 mx-auto mt-4 rounded-lg shadow-lg">
  <source src="/videos/parallel-demo.mp4" type="video/mp4" />
</SlidevVideo>

<div class="mt-3 text-center opacity-70">ESP32-P4 · 4× UART + 4× USB přes hub · každý čip má vlastní <code>esp_loader_t</code></div>

<!--
Záznam přímo z displeje P4 (main/capture.c v serial_flasher_demo), kruh = dotyk.
Pointa: výrobní linka bez PC, každý čip se flashuje ve vlastním tasku nezávisle na ostatních.
UART flashování je v záznamu zrychlené 2,5×, USB 2×.
-->

---

# Řetězový dopis 📨

### Pošli to dál, jinak tě stihne brick

<div class="grid grid-cols-[1fr_1.35fr] gap-6 mt-6 items-center">
<div>

<div class="text-2xl leading-relaxed">💾 Každé ESP přečte svůj vlastní firmware ze své flash a nahraje ho sousedovi</div>

</div>

<SlidevVideo autoplay autoreset="slide" loop muted playsinline class="w-full rounded-lg shadow-lg">
  <source src="/videos/chain-demo.mp4" type="video/mp4" />
</SlidevVideo>

</div>

<!--
ESP32-S3-LCD-EV-Board ×3 (~/Documents/My/flasher_chain). USB OTG port jako host, sousedův CP2102N jako USB-UART.
Video je 3× zrychlené.
-->

---

# Vyzkoušejte to! 🙌

- ⭐ GitHub: `github.com/espressif/esp-serial-flasher`
- 📦 ESP Component Registry: `espressif/esp-serial-flasher`
- 🔵 Arduino Library Manager: `EspSerialFlasher`
- 📱 Android: `github.com/Dzarda7/esp-flasher-android`
- 🐛 Issues a PR vítány!

---

<div class="flex items-center justify-center h-full">
<div class="font-mono text-left text-lg leading-relaxed bg-black/60 border border-gray-600 rounded-xl px-8 py-6 shadow-lg">
<div class="opacity-60">$ ./esp-serial-flasher prezentace.bin → publikum</div>
<div>Connected to target</div>
<div>Transmission rate changed.</div>
<div>Erasing flash (this may take a while)...</div>
<div>Start programming</div>
<div>Progress: 100 %</div>
<div>Finished programming</div>
<div class="text-green-400">Flash verified</div>
<div class="mt-4 text-3xl font-sans">Otázky? 🙋<span class="cursor">▌</span></div>
</div>
</div>

<style>
.cursor { animation: blink 1s steps(1) infinite; }
@keyframes blink { 50% { opacity: 0; } }
</style>

<!--
Hlášky jsou skutečné výpisy z příkladů esp-serial-flasher (examples/common/example_common.c).
-->
