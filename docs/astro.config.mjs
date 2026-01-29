// @ts-check
import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";

// https://astro.build/config
export default defineConfig({
  integrations: [
    starlight({
      title: "Frankenstack",
      social: [
        {
          icon: "github",
          label: "GitHub",
          href: "https://github.com/adiachenko/frankenstack",
        },
      ],
      sidebar: [
        { label: "Guides", autogenerate: { directory: "guides" } },
        { label: "Reference", autogenerate: { directory: "reference" } },
      ],
    }),
  ],
});
