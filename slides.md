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
- 🗣️ esptool, esptool-js, espflash, Arduino IDE, ESP-IDF… všichni mluví s ROM
- 📜 Protokol je veřejně zdokumentovaný a napříč čipy skoro stejný → může jím komunikovat každý

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

<div class="mt-10 text-3xl leading-relaxed">
esptool napsaný v C<br>
<span class="opacity-80">snadno portovatelný kamkoliv 🌍</span>
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
- 🔧 Registry, změna baudrate, reset cíle
- 🧳 Víc cílů najednou, každý svůj stav

</div>
</div>

---

# Rozhraní: jak se dostat k cíli 🔌

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

# Implementace portu: Arduino 🔵

<div class="grid grid-cols-2 gap-4 mt-2">
<div>

```cpp
struct ArduinoFlasherPort {
    esp_loader_port_t port = { &arduino_port_ops };
    HardwareSerial *serial;
    int reset_pin, boot_pin;
};

static void arduino_enter_bootloader(
    esp_loader_port_t *port)
{
    ArduinoFlasherPort *p =
        container_of(port, ArduinoFlasherPort, port);
    digitalWrite(p->boot_pin, LOW);    // BOOT dole
    digitalWrite(p->reset_pin, LOW);   // reset
    delay(100);
    digitalWrite(p->reset_pin, HIGH);  // start v ROM
    delay(50);
    digitalWrite(p->boot_pin, HIGH);
}
```

</div>
<div>

```cpp
static esp_loader_error_t arduino_write(
    esp_loader_port_t *port, const uint8_t *data,
    uint16_t size, uint32_t timeout)
{
    HardwareSerial *s = get_port(port)->serial;
    return s->write(data, size) == size
        ? ESP_LOADER_SUCCESS : ESP_LOADER_ERROR_FAIL;
}

const esp_loader_port_ops_t arduino_port_ops = {
    .init             = arduino_init,
    .enter_bootloader = arduino_enter_bootloader,
    .write            = arduino_write,
    .read             = arduino_read,
    /* … časovač, delay, log … */
};
```

</div>
</div>

<div class="mt-2 opacity-70 text-sm">Celý port ≈ 200 řádků · <code>container_of</code> → každá instance má svoje piny a UART</div>

<!--
Zjednodušeno z EspSerialFlasher.cpp (bez invert pinů a nastavitelných časů).
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
esp_loader_t loader;                                  // stav cíle: čip, stub, flash…
esp_loader_init_serial(&loader, &port.port);

esp_loader_connect_args_t args = ESP_LOADER_CONNECT_DEFAULT();
esp_loader_connect_with_stub(&loader, &args);

esp_loader_flash_cfg_t cfg = { .offset = 0x10000, .image_size = size, .block_size = 4096 };
esp_loader_flash_start(&loader, &cfg);
while (/* data */)
    esp_loader_flash_write(&loader, &cfg, chunk, chunk_len);
esp_loader_flash_finish(&loader, &cfg);               // ověří MD5
```

<div class="mt-3">🧳 Žádné globály: další cíl = další port + další <code>esp_loader_t</code> → paralelní flashování</div>

<!--
Port pro ESP32 je přímo v knihovně (port/esp32_port.h). Odkud data přijdou (SD karta, Wi-Fi, LittleFS, pole v C) je na vás.
Paralelní demo: 8 cílů = 8 portů + 8 loaderů, každý ve vlastním tasku.
-->

---

# Kolik to stojí? 🪶

<div class="text-sm opacity-70 mt-1">Jen knihovna (bez portu a libc) · connect + flash + MD5 · <code>-Os</code>, <code>--gc-sections</code>, log WARN</div>

<table class="mt-6 text-lg">
<thead><tr><th class="text-left">Varianta</th><th class="text-right">RISC-V</th><th class="text-right">Cortex-M4</th><th></th></tr></thead>
<tbody>
<tr><td>Jen ROM, bez stubu</td><td class="text-right">8,6 kB</td><td class="text-right">7,7 kB</td><td><div class="h-3 rounded bg-green-500" style="width:8px"></div></td></tr>
<tr><td>Všechny stuby (<code>connect_with_stub</code>)</td><td class="text-right">121,5 kB</td><td class="text-right">120,6 kB</td><td><div class="h-3 rounded bg-red-500" style="width:240px"></div></td></tr>
<tr><td>Jeden stub (<code>stub_provider</code>)</td><td class="text-right">18,2 kB</td><td class="text-right">17,4 kB</td><td><div class="h-3 rounded bg-yellow-500" style="width:36px"></div></td></tr>
</tbody>
</table>

<div class="mt-4">💾 0 B statické RAM · stub jde nahrát i z externí paměti</div>

<!--
Měřeno na master (7d89055), RISC-V = esp toolchain GCC 16.1 rv32imc, Cortex-M4 = arm-none-eabi 13.2. Počítají se jen objekty knihovny.
Bez logování je to o ~0,9 kB méně. MD5 je zhruba třetina (2,6 kB).
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
