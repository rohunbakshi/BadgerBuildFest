/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0f9ff',
          100: '#e0f2fe',
          200: '#bae6fd',
          300: '#7dd3fc',
          400: '#38bdf8',
          500: '#0ea5e9',
          600: '#0284c7',
          700: '#0369a1',
          800: '#075985',
          900: '#0c4a6e',
        },
        // Dashboard specific colors from Figma design
        dashboard: {
          primary: '#667eea',
          secondary: '#764ba2',
          success: '#10b981',
          text: {
            primary: '#111827',
            secondary: '#6b7280',
          },
          bg: '#f9fafb',
        },
      },
    },
  },
  plugins: [],
}

