import { describe, expect, test } from "vitest"
import { getDictionary } from "@/lib/dictionaries"
import { locales } from "@/lib/i18n"
import { installCommand, installScriptUrl, repoUrl, version } from "@/lib/site"

function unique(values: readonly string[]) {
  return new Set(values).size === values.length
}

function shape(value: unknown): unknown {
  if (Array.isArray(value)) return value.map(shape)
  if (value && typeof value === "object") return Object.fromEntries(Object.entries(value).map(([k, v]) => [k, shape(v)]))
  return typeof value === "string" || value === null ? "text" : typeof value
}

test("the version follows vX.Y.Z", () => {
  expect(version).toMatch(/^v\d+\.\d+\.\d+$/)
})

test("every language has the same content structure", () => {
  const [first, ...rest] = locales.map((l) => shape(getDictionary(l)))
  for (const other of rest) expect(other).toEqual(first)
})

describe.each(locales)("site content in %s", (locale) => {
  const { commands, cycle, install, panelRules, panelSection, shortcuts, terminals, uninstall } = getDictionary(locale)

  test("the commands are workdeck's, without duplicates", () => {
    const names = commands.map((c) => c.cmd.split(" ").slice(0, 2).join(" "))
    expect(names).toEqual(["work", "work add", "work update", "work kill", "work uninstall"])
    expect(unique(commands.map((c) => c.cmd))).toBe(true)
    for (const c of commands) expect(c.desc.length).toBeGreaterThan(0)
  })

  test("the workflow has four steps, from work add to the review in the agent", () => {
    expect(cycle).toHaveLength(4)
    expect(cycle[0].label).toBe("work add ~/api")
    expect(cycle[3].code).toBe(false)
    expect(cycle[3].desc).toContain("/code-review")
    for (const c of cycle) expect(c.desc.length).toBeGreaterThan(0)
  })

  test("the install command goes through workdeck.dev/install, which serves get.sh from the repository", () => {
    const [, owner, repo] = new URL(repoUrl).pathname.split("/")
    expect(installCommand).toBe("curl -fsSL https://workdeck.dev/install | bash")
    expect(installScriptUrl).toBe(`https://raw.githubusercontent.com/${owner}/${repo}/main/get.sh`)
    for (const steps of Object.values(install)) {
      expect(steps[0].cmd).toBe(installCommand)
      expect(steps.at(-1)?.cmd).toBe("work")
    }
  })

  test("the panels guide points to the repository", () => {
    expect(panelSection.url.startsWith(`${repoUrl}/blob/main/docs/`)).toBe(true)
  })

  test("lists used as React keys have no duplicates", () => {
    expect(unique(terminals.columns.map((c) => c.name))).toBe(true)
    expect(unique(terminals.rows.map((r) => r.label))).toBe(true)
    expect(unique(panelRules.map((r) => r.code))).toBe(true)
    expect(unique(uninstall.map((u) => u.cmd))).toBe(true)
    expect(unique(shortcuts.items.map((s) => s.desc))).toBe(true)
  })

  test("uninstall starts with work uninstall", () => {
    expect(uninstall[0].cmd).toBe("work uninstall")
  })

  test("each terminal table row has one value per terminal", () => {
    for (const r of terminals.rows) expect(r.values).toHaveLength(terminals.columns.length)
  })
})
