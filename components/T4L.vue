<template>
  <span class="t4l-wrapper">
    <span class="t4l-box"><slot /></span><sup class="t4l-sup">T4L</sup>
  </span>
</template>

<style scoped>
.t4l-wrapper {
  display: inline-block;
  white-space: nowrap;
  line-height: 1.4;
}
.t4l-box {
  display: inline-block;
  background-color: #fef3c7;
  border: 1.5px dotted #f97316;
  border-radius: 0.4rem;
  padding: 0.05rem 0.45rem;
  margin: 0;
}
.t4l-sup {
  font-size: 0.55em;
  color: #f97316;
  font-weight: bold;
  margin-left: 0.18rem;
  vertical-align: super;
  letter-spacing: 0.02em;
}
</style>
