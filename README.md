
<h1 align="center">
  <br>
  <!--
    <a href="https://github.com/KevinTyrrell/WoWProfessionOptimizer"><img src="" alt="WoWProfessionOptimizer" width="200"></a>
  -->
  <br>
  WoWProfessionOptimizer
  <br>
</h1>

<h4 align="center">World of Warcraft: Classic Addon that optimizes profession leveling using <a href="https://www.tradeskillmaster.com/" target="_blank">TSM Price Data</a>.</h4>

<p align="center">
  <a href="https://github.com/your-github-repo/blob/main/LICENSE" target="_blank">
    <img alt="GPL-3 License" src="https://img.shields.io/github/license/KevinTyrrell/WoWProfessionOptimizer?style=flat-square&color=blue" />
  </a>
  <!--
  <a href="https://badge.fury.io/js/electron-markdownify">
    <img src="https://badge.fury.io/js/electron-markdownify.svg"
         alt="Gitter">
  </a>
  <a href="https://gitter.im/amitmerchant1990/electron-markdownify"><img src="https://badges.gitter.im/amitmerchant1990/electron-markdownify.svg"></a>
  <a href="https://saythanks.io/to/bullredeyes@gmail.com">
      <img src="https://img.shields.io/badge/SayThanks.io-%E2%98%BC-1EAEDB.svg">
  </a>
  <a href="https://www.paypal.me/AmitMerchant">
    <img src="https://img.shields.io/badge/$-donate-ff69b4.svg?maxAge=2592000&amp;style=flat">
  </a>
  -->
</p>

<p align="center">
  <a href="#introduction">Introduction</a> •
  <a href="#guide-generation">Guide Generation</a> •
  <a href="#faq">FAQ</a> •
  <a href="#download">Download</a> •
  <a href="#license">License</a>
</p>

![screenshot](res/UnderConstruction.jpg)

## Introduction

> WoWProfessionOpimizer is  a powerful add-on for World of Warcraft: Classic. Its primary goal is to revolutionize the traditional approach to leveling professions by replacing static profession leveling guides. The add-on generates guides dynamically using an optimized brute force algorithm. The guides are integrated into the game, allowing for a customizable experience.

## Guide Generation

> Users must/may provide the following information before generating a guide:

* **Profession** - e.g. <span style="color: gold;">[Engineering]</span>
* **Skill Start / Target** - e.g. <span style="color: lightblue;">1</span> to <span style="color: lightblue;">450</span>
* **Recipe Sources** - e.g. Trainer✅/Vendor✅/Drop❌/Auction House❌
* **Crafts Ban / Limits** - Prevent or restrict craft-count of certain crafting recipes
* **Crafts Mandate** - Enforce certain crafts to be made efficiently along the way
* **Bi-Product Disposal** - per-item specification of what to do with un-needed items
  - e.g. <span style="color: #1eff00;">[Deadly Blunderbus]</span>: Disenchant❌/Auction House:✅/Vendor:✅
  - *Limitations on auction house* - **Limit Num Sold** or **Diminishing Returns**

## FAQ

---

#### Q: Why are static guides undesirable?

A: As most people use the same popular guides, this drives up demand on a small subset of items in the game. For example, a recipe using <span style="color: #1eff00;">[Aquamarine]</span> may have been originally economical, but as all profession levelers dog-pile on that one item, it causes prices to balloon, no longer being the cheapest route to level. More-over, the guides often remain static for years, and assume generalizations across servers. Most importantly, static guides do not factor in **profits made from crafts** while leveling.

---

#### Q: How does the add-on know prices of items?

A: TSM ([TradeSkillMaster](https://www.tradeskillmaster.com/)) provides nearly real-time information on auction house, vendor, and disenchanting prices for every non-soulbound item in the game. Ensure TSM and TSM_AppHelper are installed and loaded before using this add-on.

---

#### Q: How does the add-on handle RNG craft skill-ups?

A: WoWProfessionOptimizer handles random skill-ups by computing the average number of crafts needed to ascend one skill level. [WoWWiki's Profession Page](https://wowpedia.fandom.com/wiki/Profession#Increasing_professional_skill_level) dictates the chance for a skill as the following formula:

```js
chance = (greySkill - yourSkill) / (greySkill - yellowSkill)
```

<span style="color: white;">[Unstable Trigger]</span> has a skill breakdown of { <span style="color: orange;">200</span> <span style="color: yellow;">200</span> <span style="color: lightgreen;">220</span> <span style="color: grey;">240</span> }. If you had a skill level of <span style="color: lightblue;">235</span> then the craft would be <span style="color: lightgreen;">green</span>. Plugging this into the formula would yield the following:

```js
chance = (240 - 235) / (240 - 220) // 0.25 or 25%
```

This means you would have only a <span style="color: white;">25%</span> chance of getting a skill-up from crafting an <span style="color: white;">[Unstable Trigger]</span> at <span style="color: lightblue;">235</span>. The add-on takes the inverse of this <span style="color: white;">1 / 0.25 => 4</span>, indicating four crafts of <span style="color: white;">[Unstable Trigger]</span> are needed to reach <span style="color: lightblue;">236</span>.

---

#### Q: How does the guide generation algorithm work?

A: **Brute force** - **Backtracking** - **Pruning**. At each skill level, the guide will look over all crafts that generate a skill increase. It will pick one item, craft it until a skill-up is achieved, and tally the cost into a gold-spent sum. If the crafted item is a bi-product, it is sold according to the user's specifications, otherwise it is kept for later. If the current gold-tally exceeds a known-best route, the algorithm backtracks one step, recursively. Routes which show no promise are pruned prematurely to save on run-time complexity.

---

## Download

You can [download](https://github.com/KevinTyrrell/WoWProfessionOptimizer/releases) the latest release on the 'Releases' page.
 
> **Note**
> For manual installation, ensure your path to the add-on's TOC (Table of Contents) is similar to as follows:

``` 
C:/Program Files (x86)/World of Warcraft/_classic_/Interface/AddOns/WoWProfessionOptimizer/WoWProfessionOptimizer.toc
```

## Support

[![Donate with PayPal](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/donate/?business=ZYQ7AJ9R57FTY&no_recurring=0&item_name=Software+Developer&currency_code=USD)

## License

[GNU General Public License version 3](LICENSE)

---

> GitHub [@KevinTyrrell](https://github.com/KevinTyrrell) &nbsp;&middot;&nbsp;
> Curseforge [@hatefiend](https://legacy.curseforge.com/members/hatefiend/projects) &nbsp;&middot;&nbsp;
> Wago [@hatefiend](https://wago.io/p/Hatefiend) &nbsp;&middot;&nbsp;
> Discord [@hatefiend](https://www.discord.com)

