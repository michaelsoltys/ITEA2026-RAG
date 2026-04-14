<template>
  <div v-if="$slidev.nav.currentPage > 1 && $slidev.nav.currentPage < $slidev.nav.total" class="slide-page-number">
    <SlideCurrentNo /> / <SlidesTotal />
  </div>
</template>

<style scoped>
.slide-page-number {
  position: absolute;
  bottom: 1.5rem;
  left: 50%;
  transform: translateX(-50%);
  font-size: 0.875rem;
  opacity: 0.5;
  font-weight: bold;
  z-index: 10;
}
</style>
