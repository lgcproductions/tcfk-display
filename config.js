'use strict';

function deepcopy(o) {
  return JSON.parse(JSON.stringify(o))
}

const store = new Vuex.Store({
  strict: true,
  state: {
    assets: {},
    node_assets: {},
    config: {
      pages: [],
      gpio: {        // <-- add GPIO defaults
        up: 17,
        down: 18,
        select: 27,
        menu: 22,
        power: 23
      },
      menu: [        // <-- editable menu items
        { id: "wedding", label: "Wedding fayre" },
        { id: "light", label: "Serving Times (light mode)" },
        { id: "dark", label: "Serving Times (dark mode)" }
      ]
    },
  },
  mutations: {
    init(state, {assets, node_assets, config}) {
      state.assets = assets;
      state.node_assets = node_assets;
      state.config = config;
      // fallback to defaults if missing
      if (!state.config.gpio) state.config.gpio = {
        up: 17, down: 18, select: 27, menu: 22, power: 23
      };
      if (!state.config.menu) state.config.menu = [
        { id: "wedding", label: "Wedding fayre" },
        { id: "light", label: "Serving Times (light mode)" },
        { id: "dark", label: "Serving Times (dark mode)" }
      ];
    },
    set_option(state, {key, value}) {
      Vue.set(state.config, key, value);
    },
    set_gpio(state, {pin, value}) {
      Vue.set(state.config.gpio, pin, value);
    },
    set_menu_item(state, {index, key, value}) {
      Vue.set(state.config.menu[index], key, value);
    },
    add_menu_item(state, index) {
      const new_item = { id: "new", label: "New item" };
      state.config.menu.splice(index + 1, 0, new_item);
    },
    remove_menu_item(state, index) {
      state.config.menu.splice(index, 1);
    },
    // Keep your existing page mutations...
    remove_page(state, index) { state.config.pages.splice(index, 1); },
    create_page(state, index) { /* ... */ },
    create_pages(state, opt) { /* ... */ },
    set_layout(state, {index, layout}) { /* ... */ },
    set_schedule_hour(state, {index, hour, on}) { /* ... */ },
    set_media(state, {index, media}) { /* ... */ },
    set_duration(state, {index, duration}) { /* ... */ },
    set_config(state, {index, key, value}) { /* ... */ },
  },
  actions: {
    init(context, values) { context.commit('init', values); },
    set_option(context, update) { context.commit('set_option', update); },
    set_gpio(context, update) { context.commit('set_gpio', update); },
    set_menu_item(context, update) { context.commit('set_menu_item', update); },
    add_menu_item(context, index) { context.commit('add_menu_item', index); },
    remove_menu_item(context, index) { context.commit('remove_menu_item', index); },
    // Pages actions...
    remove_page(context, index) { context.commit('remove_page', index); },
    create_page(context, index) { context.commit('create_page', index); },
    create_pages(context, opt) { context.commit('create_pages', opt); },
    set_layout(context, update) { context.commit('set_layout', update); },
    set_schedule_hour(context, update) { context.commit('set_schedule_hour', update); },
    set_media(context, update) { context.commit('set_media', update); },
    set_duration(context, update) { context.commit('set_duration', update); },
    set_config(context, update) { context.commit('set_config', update); },
  }
});

// Component for GPIO config
Vue.component('gpio-config', {
  template: `
    <div>
      <h4>GPIO Pins</h4>
      <div v-for="(value, pin) in config.gpio" :key="pin">
        <label>{{pin}}:</label>
        <input type="number" v-model.number="config.gpio[pin]" @change="onUpdate(pin)">
      </div>
    </div>
  `,
  computed: {
    config() { return this.$store.state.config; }
  },
  methods: {
    onUpdate(pin) {
      this.$store.dispatch('set_gpio', { pin: pin, value: this.config.gpio[pin] });
    }
  }
});

// Component for editable menu items
Vue.component('menu-config', {
  template: `
    <div>
      <h4>Menu Items</h4>
      <div v-for="(item, index) in config.menu" :key="index">
        <label>ID:</label>
        <input type="text" v-model="item.id" @change="update(index, 'id', item.id)">
        <label>Label:</label>
        <input type="text" v-model="item.label" @change="update(index, 'label', item.label)">
        <button @click="remove(index)">Remove</button>
      </div>
      <button @click="add">Add new item</button>
    </div>
  `,
  computed: {
    config() { return this.$store.state.config; }
  },
  methods: {
    update(index, key, value) {
      this.$store.dispatch('set_menu_item', { index, key, value });
    },
    add() {
      this.$store.dispatch('add_menu_item', this.config.menu.length - 1);
    },
    remove(index) {
      this.$store.dispatch('remove_menu_item', index);
    }
  }
});

// Initialize Vue
const app = new Vue({
  el: "#app",
  store,
});

ib.setDefaultStyle();
ib.ready.then(() => {
  ib.onAssetUpdate(() => store.commit('assets_update', ib.assets));
  store.dispatch('init', {
    assets: ib.assets,
    node_assets: ib.node_assets,
    config: ib.config,
  });
  store.subscribe((mutation, state) => {
    ib.setConfig(state.config);
  });
});
