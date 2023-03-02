/** @type {import('tailwindcss').Config} */
// eslint-disable-next-line no-undef
module.exports = {
  content: ["./index.html", "./src/**/*.{vue,js,ts,jsx,tsx}"],
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        code: {
          highlight: "rgb(125 211 252 / 0.1)",
        },
        discord: "#5865F2",
        blue: {
          DEFAULT: "#1E22AA",
          50: "#9496EC",
          100: "#8285E9",
          200: "#6063E3",
          300: "#3D41DD",
          400: "#2126c5",
          500: "#1E22AA",
          600: "#16187A",
          700: "#0D0F4B",
          800: "#090A31",
          900: "#05051A",
        },
        orange: {
          DEFAULT: "#FF6D2B",
          50: "#FFEBE3",
          100: "#FFDDCE",
          200: "#FFC1A5",
          300: "#FFA57D",
          400: "#FF8954",
          500: "#FF6D2B",
          600: "#F24B00",
          700: "#BA3A00",
          800: "#822800",
          900: "#4A1700",
        },
        creme: {
          DEFAULT: "#F1EEE6",
          50: "#FDFDFC",
          100: "#FBFBF8",
          200: "#FAF8F5",
          300: "#F8F6F2",
          400: "#F4F2EB",
          500: "#F1EEE6",
          600: "#EDEADF",
          700: "#E2DCCC",
          800: "#D7CFB8",
          900: "#CBBFA1",
        },
      },
    },
  },
  // eslint-disable-next-line no-undef
  plugins: [
    // eslint-disable-next-line no-undef
    require("@tailwindcss/forms"),
    function ({ addVariant }) {
      addVariant("scrollbar", "&::-webkit-scrollbar");
      addVariant("scrollbar-track", "&::-webkit-scrollbar-track");
      addVariant("scrollbar-thumb", "&::-webkit-scrollbar-thumb");
    },
  ],
};
