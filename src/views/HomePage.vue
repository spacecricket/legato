<script setup>
import Toolbar from 'primevue/toolbar'
</script>

<template>
  <div class="home flex flex-col h-dvh">
    <div class="w-dvw">
      <Toolbar>
        <template #start>
          <div class="flex items-center p-6">
            <div class="flex flex-col">

              <div class="text-4xl font-bold text-lime-500">💬 Legato</div>
              <div class="text-lg font-extralight text-gray-300">
                Focus-first chat inspired by 37 Signals'
                <a href="https://37signals.com/group-chat-problems" target="_blank"><u>Group Chat Problems</u></a>
              </div>
            </div>
          </div>
        </template>
      </Toolbar>
    </div>

    <div
      class="w-full bg-neutral-800 text-center font-stretch-ultra-condensed opacity-75 text-white text-9xl p-8 font-extralight">
      COMING<br />SOON
    </div>

    <div class="w-full bg-neutral-900 text-center opacity-75 text-white font-extralight text-sm p-1">
      Read: <a href="https://jatinsonavane.substack.com/p/old-man-yells-at-slack" target="_blank"><u>An old man yells at
          Slack</u></a>
    </div>
  </div>
</template>

<style scoped>
.home {
  background-image: url("/bg-dark.png");
  background-size: cover;
  background-position: center center;
  background-repeat: no-repeat;
  background-attachment: fixed;
  min-height: 100vh;
}

.p-toolbar {
  background-color: black;
  border: none !important;
  border-radius: 0;
}
</style>
