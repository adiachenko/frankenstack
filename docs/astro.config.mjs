// @ts-check
import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";

// https://astro.build/config
export default defineConfig({
  site: "https://frankenstack.vercel.app",
  redirects: {
    "/": "/guides/introduction/",
  },
  integrations: [
    starlight({
      title: "Frankenstack",
      description:
        "Laravel-ready FrankenPHP Docker image with classic and worker modes, runtime-configurable PHP settings, and bundled developer tooling.",
      customCss: ["./src/styles/custom.css"],
      // Disable dark mode - light only
      components: {
        ThemeProvider: "./src/components/ThemeProvider.astro",
        ThemeSelect: "./src/components/ThemeSelect.astro",
      },
      expressiveCode: {
        themes: ["github-light"],
        styleOverrides: {
          borderRadius: "0.5rem",
        },
      },
      social: [
        {
          icon: "github",
          label: "GitHub",
          href: "https://github.com/adiachenko/frankenstack",
        },
      ],
      sidebar: [
        { label: "Guides", autogenerate: { directory: "guides" } },
        { label: "Concepts", autogenerate: { directory: "concepts" } },
        { label: "Reference", autogenerate: { directory: "reference" } },
      ],
    }),
  ],
});
