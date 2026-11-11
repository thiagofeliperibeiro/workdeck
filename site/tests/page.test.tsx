import { describe, expect, test, vi } from "vitest"
import { render, screen, within } from "@testing-library/react"
import Home from "@/app/[lang]/page"
import { getDictionary } from "@/lib/dictionaries"
import { installCommand, repoUrl } from "@/lib/site"

vi.mock("next/font/google", () => ({ Geist: () => ({ variable: "" }), JetBrains_Mono: () => ({ variable: "" }) }))

const github = vi.hoisted(() => ({ stars: 23456 as number | null, version: "v9.8.7" }))

vi.mock("@/lib/github", () => ({ getStars: async () => github.stars, getVersion: async () => github.version }))

vi.mock("next/navigation", async (original) => ({
  ...(await original<typeof import("next/navigation")>()),
  useRouter: () => ({ push: vi.fn() }),
}))

function page(lang = "pt-BR") {
  return Home({ params: Promise.resolve({ lang }) } as PageProps<"/[lang]">)
}

describe("home page", () => {
  test("the GitHub link in the header shows the stars", async () => {
    github.stars = 23456
    render(await page())
    const link = within(screen.getByRole("banner")).getByRole("link", { name: "GitHub, 23456 estrelas" })
    expect(link.getAttribute("href")).toBe(repoUrl)
    expect(link.textContent).toBe("+23K")
  })

  test.each([null, 0, 9])("with %s stars, the link shows only GitHub", async (stars) => {
    github.stars = stars
    render(await page())
    expect(within(screen.getByRole("banner")).getByRole("link", { name: "GitHub" }).textContent).toBe("GitHub")
    github.stars = 23456
  })

  test("from 10 stars on, the number appears", async () => {
    github.stars = 10
    render(await page())
    expect(within(screen.getByRole("banner")).getByRole("link", { name: "GitHub, 10 estrelas" }).textContent).toBe("10")
    github.stars = 23456
  })

  test("has the main heading", async () => {
    render(await page())
    expect(screen.getByRole("heading", { level: 1 }).textContent).toContain("framework de terminal para agentes de IA")
  })

  test("each menu link points to an existing section", async () => {
    const { container } = render(await page())
    const nav = screen.getByRole("navigation")
    const links = within(nav).getAllByRole("link")
    expect(links.length).toBeGreaterThan(0)
    for (const link of links) {
      const id = link.getAttribute("href")?.slice(1)
      expect(id && container.querySelector(`#${id}`)).toBeTruthy()
    }
  })

  test("shows every command", async () => {
    render(await page())
    for (const c of getDictionary("pt-BR").commands) expect(screen.getAllByText(c.cmd).length).toBeGreaterThan(0)
  })

  test("shows the version, GitHub and the install command", async () => {
    render(await page())
    expect(screen.getByText(new RegExp(`${github.version} · open source`))).toBeTruthy()
    expect(document.querySelectorAll(`a[href="${repoUrl}"]`).length).toBeGreaterThan(0)
    expect(screen.getAllByText(installCommand).length).toBeGreaterThan(0)
    expect(screen.queryByText(/em breve/)).toBeNull()
  })

  test("in English, the heading, the menu and the language notice are in English", async () => {
    render(await page("en"))
    expect(screen.getByRole("heading", { level: 1 }).textContent).toContain("terminal framework for AI agents")
    expect(within(screen.getByRole("navigation")).getByRole("link", { name: "How it works" })).toBeTruthy()
    expect(screen.getByText(/speaks English or Brazilian Portuguese/)).toBeTruthy()
  })

  test("the language switcher marks the current language", async () => {
    render(await page("en"))
    const group = screen.getByRole("group", { name: "Language" })
    expect(within(group).getByRole("button", { name: "EN" }).getAttribute("aria-pressed")).toBe("true")
    expect(within(group).getByRole("button", { name: "PT" }).getAttribute("aria-pressed")).toBe("false")
  })

  test("the keyboard section shows the workdeck shortcuts and the note for other terminals", async () => {
    const { container } = render(await page("en"))
    const keyboard = within(container.querySelector("#atalhos") as HTMLElement)
    expect(keyboard.getByRole("tab", { name: "macOS" })).toBeTruthy()
    expect(keyboard.getByRole("tab", { name: "Linux" })).toBeTruthy()
    expect(keyboard.getByText("Opens the agent in a new pane, with the diff beside it")).toBeTruthy()
    expect(keyboard.queryByText(/work review/)).toBeNull()
    expect(keyboard.getByText("Other terminals")).toBeTruthy()
  })

  test("an unknown language is not found", async () => {
    await expect(page("fr")).rejects.toThrow()
  })
})
