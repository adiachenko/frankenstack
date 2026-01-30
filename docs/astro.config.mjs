// @ts-check
import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";

// https://astro.build/config
export default defineConfig({
  integrations: [
    starlight({
      title: "Frankenstack",
      customCss: ["./src/styles/custom.css"],
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
