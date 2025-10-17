import { createRouter, createWebHistory } from 'vue-router'
import HomePage from '@/views/HomePage.vue'

/**
 * This file just list the routes and the components (aka views)
 * that serve them.
 */
const routes = [
  {
    path: '/',
    name: 'Home',
    component: HomePage,
  },
  {
    path: '/:org',
    name: 'Chat',
    component: () => import('@/views/ChatPage.vue'),
  },
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
})

export default router
