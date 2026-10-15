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
- 🗣️ esptool, esptool-js, espflash, Arduino IDE, ESP-IDF… všichni mluví s ROM
- 📜 Protokol je veřejně zdokumentovaný a napříč čipy skoro stejný → může ho mluvit kdokoliv

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

<div class="grid grid-cols-2 gap-x-8 mt-4 text-left">
<div>

- 🔗 Připojení, autodetekce čipu, MAC, security info
- 💾 Flash: zápis, čtení, mazání, ověření MD5
- 🗜️ Komprimovaný zápis (deflate)
- 🧮 Nahrání a spuštění kódu v RAM

</div>
<div>

- 🚀 Flasher stub: rychlejší, vyšší baudrate
- 🔐 eFuse: čtení, zápis eFuse a klíčů
- 🔧 Registry, změna baudrate, reset cíle
- 🪶 Platíte jen za to, co použijete

</div>
</div>

<div class="mt-6 opacity-70">🔓 Open source, Apache 2.0</div>

<!--
Stub je volitelný: bez stubu (jen ROM) ~9 KB flash, jen stuby pro vaše čipy, nebo stub z externí paměti.
eFuse tabulky se linkují jen pro vybrané čipy.
-->

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

# Rozhraní: jak se dostat k cíli 🔌

<div class="grid grid-cols-2 gap-4 mt-4 text-left">

<div class="border border-gray-600 rounded-lg px-4 py-2">
<b>🧵 UART</b> <span class="opacity-70 text-sm">+ BOOT a RESET pin</span><br>
<span class="text-sm">Všechno umí, všechny čipy od ESP8266 po S31</span>
</div>

<div class="border border-gray-600 rounded-lg px-4 py-2">
<b>🔌 USB-Serial-JTAG / USB CDC</b><br>
<span class="text-sm">Bez převodníku a bez extra pinů, reset řeší USB<br>S3, C3, C5, C6, C61, H2, H21, H4, P4, S31</span>
</div>

<div class="border border-gray-600 rounded-lg px-4 py-2">
<b>⚡ SPI</b> <span class="opacity-70 text-sm">jen nahrání do RAM</span><br>
<span class="text-sm">Rychlý start kódu bez flashování<br>S3, C2, C3, H2</span>
</div>

<div class="border border-gray-600 rounded-lg px-4 py-2">
<b>💾 SDIO</b> <span class="opacity-70 text-sm">experimentální</span><br>
<span class="text-sm">Plný stub přes SDIO: flash, čtení, eFuse<br>C5, C6</span>
</div>

</div>

<div class="mt-6 text-left">

🖥️ <b>Porty v knihovně:</b> ESP32 (UART, USB CDC, SPI, SDIO), STM32, Raspberry Pi Pico, Zephyr, Linux<br>
<span class="opacity-70">Mimo knihovnu: 🆕 Arduino, 🆕 Android</span>

</div>

<!--
Podle tabulky v README esp-serial-flasher. Ve vývoji: SPI pro H21, P4, H4; SDIO pro ESP32 a C61.
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

# Stav patří instanci, ne globálu 🧳

```c {all|1-6|8-9|11-14|all}
typedef struct {
    esp_loader_port_t port;          // ukazatel na ops
    uint32_t   uart_port;
    gpio_num_t uart_rx_pin, uart_tx_pin, reset_pin, boot_pin;
    /* … privátní stav portu … */
} esp32_port_t;

esp32_port_t port_a = { .port.ops = &esp32_uart_ops, .uart_port = UART_NUM_1, /* … */ };
esp32_port_t port_b = { .port.ops = &esp32_uart_ops, .uart_port = UART_NUM_2, /* … */ };

esp_loader_t loader_a, loader_b;                 // stav cíle: čip, stub, flash…
esp_loader_init_serial(&loader_a, &port_a.port);
esp_loader_init_serial(&loader_b, &port_b.port);
```

- 🎯 `esp_loader_t` drží stav cíle, port drží stav hardwaru
- 🚫 Žádné globální proměnné → libovolný počet cílů najednou, každý ve svém tasku
- 🔁 V callbacku `container_of(port, esp32_port_t, port)` → vlastní data

<!--
Tohle umožňuje paralelní flasher z dema: 8 cílů, 8 loaderů, 8 portů.
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

# 🔵 Arduino

<div class="grid grid-cols-[1.15fr_1fr] gap-6 mt-2">
<div>

```cpp {all|7-9|11-13|all}
#include <EspSerialFlasher.h>

ArduinoFlasherPort port;
esp_loader_t loader;

void setup() {
  port.serial    = &Serial1;
  port.reset_pin = TARGET_EN;
  port.boot_pin  = TARGET_BOOT;

  esp_loader_init_serial(&loader, &port.port);
  esp_loader_connect_args_t args = ESP_LOADER_CONNECT_DEFAULT();
  esp_loader_connect_with_stub(&loader, &args);
  // … a dál stejné C API jako všude jinde
}
```

</div>
<div>

<img src="/images/arduino-wiring.svg" class="w-full" />

- 🔌 UART + 2 GPIO, libovolná deska
- 📦 Arduino IDE (.zip) i PlatformIO
- 🔁 Upstream 1:1, vlastní je jen port
- 📁 Příklad `FlashFromFile` (LittleFS)

🔗 [github.com/Dzarda7/EspSerialFlasher](https://github.com/Dzarda7/EspSerialFlasher)

</div>
</div>

<!--
Celý sketch: File → Examples → EspSerialFlasher → FlashFromFile.
Zbytek (flash_start/write/finish) je stejný jako na slidu „Použití“.
-->

---
class: text-left
---

<div class="absolute left-4 top-2 bottom-2 w-80">
  <SlidevVideo autoplay autoreset="slide" loop muted playsinline class="h-full mx-auto rounded-xl shadow-lg">
    <source src="/videos/android-demo.mp4" type="video/mp4" />
  </SlidevVideo>
</div>

<div class="ml-76">

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

<div class="mt-3 text-center opacity-70">ESP32-P4 · 4× UART + 4× USB přes hub · každý cíl má vlastní <code>esp_loader_t</code></div>

<!--
Záznam přímo z displeje P4 (main/capture.c v serial_flasher_demo), kruh = dotyk.
Pointa: výrobní linka bez PC, každý cíl běží ve vlastním tasku nezávisle na ostatních.
UART flashování je v záznamu zrychlené 2,5×, USB 2×.
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

# Vyzkoušejte to! 🙌

- ⭐ GitHub: `github.com/espressif/esp-serial-flasher`
- 📦 ESP Component Registry: `espressif/esp-serial-flasher`
- 🔵 Arduino: `github.com/Dzarda7/EspSerialFlasher`
- 📱 Android: `github.com/Dzarda7/esp-flasher-android`
- 🐛 Issues a PR vítány, hlavně nové porty!

---

<div class="flex items-center justify-center h-full">
  <div class="text-center text-4xl">
  Díky! 🙏<br><br>Otázky?
  </div>
</div>
