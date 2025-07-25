const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  darkMode: 'class',
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  safelist: [
    'dark:bg-gray-800',
    'dark:bg-gray-900', 
    'dark:text-gray-100',
    'dark:text-gray-400',
    'dark:border-gray-600',
    'dark:border-gray-700',
    'dark:bg-blue-600',
    'dark:bg-blue-900',
    'dark:hover:bg-blue-700'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ]
}