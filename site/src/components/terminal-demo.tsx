"use client"

import { Caret, Line, Pane, Prompt, StatusBar, TerminalWindow, Typed, useTimeline } from "@/components/terminal-parts"
import type { Dictionary } from "@/lib/dictionaries"

const timeline = [700, 900, 900, 700, 1600, 700, 700, 900, 1100, 900, 5200]

export function TerminalDemo({ demo }: { demo: Dictionary["demo"] }) {
  const s = useTimeline(timeline)

  const agentOpen = s >= 3

  return (
    <TerminalWindow>
        <div className="grid h-[560px] grid-rows-[1fr_auto] gap-0 font-mono text-[11.5px] leading-relaxed sm:h-[380px] sm:text-xs">
          <div className="grid min-h-0 grid-cols-1 p-1.5">
            <Pane title={agentOpen ? demo.agentPane : "shell"} active>
              <Prompt text="work" typing={s === 0} done={s >= 1} caret={s === 0} />
              {s >= 1 && (
                <Line className="text-ctp-overlay1">
                  {demo.session} <span className="text-ctp-mauve">work</span> · {demo.windows}
                </Line>
              )}
              {s >= 2 && <Prompt text="claude" typing={s === 2} done={s >= 3} caret={s === 2} />}
              {agentOpen && (
                <Line className="mt-1">
                  <span className="text-ctp-peach">› </span>
                  <span className="text-ctp-text">{demo.prompt}</span>
                </Line>
              )}
              {s >= 4 && (
                <>
                  <Line className="text-ctp-subtext0" delay={0.1}>  {demo.reading} src/auth/login.ts</Line>
                  <Line className="text-ctp-subtext0" delay={0.5}>  {demo.creating} src/auth/email.ts</Line>
                  <Line className="text-ctp-subtext0" delay={0.9}>  {demo.editing} src/auth/login.ts</Line>
                </>
              )}
              {s >= 5 && <Line className="text-ctp-green">  {demo.done}</Line>}
              {s >= 6 && <Line><span className="text-ctp-peach">› </span><span className="text-ctp-text">{s >= 7 ? "/code-review" : <Typed text="/code-review" />}</span><Caret show={s === 6} /></Line>}
              {s >= 7 && <Line className="mt-1 text-ctp-text" delay={0.05}>  {demo.reviewFound}</Line>}
              {s >= 8 && <Line className="text-ctp-subtext0" delay={0.05}>  email.ts:3   <span className="text-ctp-text">{demo.issueEmail}</span></Line>}
              {s >= 9 && <Line className="text-ctp-subtext0" delay={0.05}>  login.ts:13  <span className="text-ctp-text">{demo.issueTest}</span></Line>}
            </Pane>
          </div>

          <StatusBar windows={["painel", "api", "web", "notas"]} active={2} starred={s === 5 ? 2 : undefined} branch="feature/login" />
        </div>
    </TerminalWindow>
  )
}
