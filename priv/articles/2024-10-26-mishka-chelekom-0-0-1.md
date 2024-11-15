---
title: Mishka Chelekom 0.0.1 has been released
headline: Explore the power of Mishka Chelekom's first release — the ultimate UI kit for Phoenix developers, crafted for flexibility and efficiency.
read_time: 2
tags:
  - Mishka
  - Phoenix
  - LiveView
author:
  full_name: Shahryar Tavakkoli
  image: shahryar-tavakkoli.jpg
  twitter: https://x.com/shahryar_tbiz
  linkedin: https://www.linkedin.com/in/shahryar-tavakkoli
  github: https://github.com/shahryarjb
description: Discover the first release of Mishka Chelekom, a UI kit and Phoenix component library built for developers. Get access to over 80 components, learn about our foundational approach with no JavaScript dependencies, and see how you can use it for your projects.
keywords: Mishka Chelekom, Phoenix components, LiveView UI kit, Phoenix framework, Tailwind CSS, Phoenix CLI
image: /images/blog/mishka-chelekom-0.0.1.png
language: EN
---

<br />

<p align="center">
<img src="/images/blog/mishka-chelekom-0.0.1.png" alt="Mishka Chelekom 0.0.1 has been released">
</p>

<br />

<.heading2>Announcing the First Release of Mishka Chelekom UI Kit & Phoenix Components</.heading2>

<.cp>After three and a half months of full-time work, we have released the first version of
our <.clink navigate="/chelekom"><strong>UI kit and components for Phoenix and LiveView</strong></.clink>.</.cp>

<.cp>This release is built around the idea of providing foundational components for
the **Phoenix framework** without requiring any production dependencies or using JavaScript.</.cp>

<.cp>**Version 0.0.1** of the Mishka Chelekom library, powered by
the <.clink href="https://github.com/ash-project/igniter" target="_blank">Igniter</.clink> project,
allows developers to access over **80 components across 43 different categories** through CLI.</.cp>

<.cp>This means you can easily generate a module for a specific component (e.g., an alert) in
your Phoenix project by running a simple command. Each component also comes with various parameters,
allowing you to avoid bloating your project with unused styles.</.cp>

<.cp>For instance, if you don’t need a black color in your project, you don't need to include it.
If you decide you need it later, the CLI will assist you by showing a diff compared to the
previous version and updating the project after your approval.</.cp>

<.cp>In this initial version, our goal is to lay down the foundation for all the essentials needed
for an admin panel. That's why we haven't yet focused on JavaScript or CSS animations —
although we definitely have long-term plans for these as well.</.cp>

<br />

---

<.heading2>Why Did We Create Mishka Chelekom?</.heading2>

As a team, we are big fans of projects like Live Svelte and LiveVue, but we felt strongly that we shouldn't simply follow the same path as the JavaScript community. Instead, we wanted to solve the initial problems first and only add complexity if truly needed — offering these tools to developers as an option, not a requirement. With that in mind, we decided to build all foundational features using native LiveView.

**Will we use these projects in the future?** Absolutely, but as optional extras. Our primary goal will always be to continue building powerful native Phoenix components.

We aim to take a hybrid approach, utilizing both client-side functionality through **LiveView** and pure JavaScript in phx-hook. This gives developers the option to fully customize their applications or use it with minimal knowledge as simply as possible.

You can start using this project by visiting our documentation page. The entire project has been developed using **Tailwind CSS**, without the use of other tools. The latest version of LiveView, currently in RC, has also been targeted.

<br />

---

<.heading2>Important Notes about our entry goal:</.heading2>


<LiveViewBackWeb.List.list variant="transparent" size="medium" style="list-decimal" class="px-10">
  <:item padding="small">
    Due to our focus on foundational functionality, some components may have limitations in this version.
    Once we integrate JavaScript into the project, we will offer more component versions for you to
    choose from. It's all about software trade-offs, and soon you’ll have more options to pick the
    best one for your needs.
  </:item>
  <:item padding="small">
    All components in this release are **light mode** only. Dark mode will be available in the next version.
    You can also check out our roadmap for upcoming features.
  </:item>
  <:item padding="small">
    After a few more updates, we will begin creating short videos on converting graphic templates,
    such as admin panels, to **heex**. These tutorial videos will help you get the best out of
    this library much more quickly.
  </:item>
</LiveViewBackWeb.List.list>

<br />

---

<.custom_block position="left" color="success" class="my-8" border="medium">
  Please help us test and improve the project by opening an issue on our GitHub repository:
  <br />
  [https://github.com/mishka-group/mishka_chelekom](https://github.com/mishka-group/mishka_chelekom)
</.custom_block>
