<!--
  Shows the phone screen streamed by scrcpy into a v4l2loopback camera labelled "Phone".
  Start it with ./phone.sh before the talk.
-->
<script setup lang="ts">
import { onMounted, onUnmounted, ref } from 'vue'

const props = withDefaults(defineProps<{ label?: string }>(), { label: 'Phone' })

const video = ref<HTMLVideoElement>()
const status = ref('')
const needsClick = ref(false)
let stream: MediaStream | undefined

async function start() {
  needsClick.value = false
  status.value = 'Hledám telefon…'
  try {
    // Device labels are only visible once camera permission is granted
    const probe = await navigator.mediaDevices.getUserMedia({ video: true })
    probe.getTracks().forEach(t => t.stop())

    const devices = await navigator.mediaDevices.enumerateDevices()
    const phone = devices.find(d => d.kind === 'videoinput' && d.label.includes(props.label))
    if (!phone) {
      status.value = 'Telefon nenalezen – běží ./phone.sh?'
      return
    }
    stream = await navigator.mediaDevices.getUserMedia({ video: { deviceId: { exact: phone.deviceId } } })
    video.value!.srcObject = stream
    status.value = ''
  }
  catch (e) {
    status.value = `Kamera nedostupná: ${(e as Error).message}`
  }
}

// Visitors of the public deck should not get a camera prompt, so auto-start only once
// camera access was already granted on this origin; otherwise wait for a click.
onMounted(async () => {
  const perm = await navigator.permissions?.query({ name: 'camera' as PermissionName }).catch(() => undefined)
  if (perm?.state === 'granted')
    start()
  else
    needsClick.value = true
})
onUnmounted(() => stream?.getTracks().forEach(t => t.stop()))
</script>

<template>
  <div class="relative h-full flex items-center justify-center">
    <video ref="video" autoplay muted playsinline class="h-full rounded-xl shadow-lg" />
    <button v-if="needsClick" class="absolute inset-0 flex items-center justify-center text-xl border-2 border-dashed rounded-xl opacity-70 hover:opacity-100" @click="start">
      📱 Připojit telefon
    </button>
    <div v-else-if="status" class="absolute inset-0 flex items-center justify-center text-center opacity-60 border-2 border-dashed rounded-xl p-4">
      {{ status }}
    </div>
  </div>
</template>
