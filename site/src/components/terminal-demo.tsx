"use client"

import { AnimatePresence, motion } from "motion/react"
import { Caret, Line, Pane, Prompt, StatusBar, TerminalWindow, Typed, useTimeline } from "@/components/terminal-parts"
import type { Dictionary } from "@/lib/dictionaries"
import { cn } from "@/lib/utils"

const timeline = [700, 900, 800, 700, 1600, 700, 600, 700, 900, 1100, 900, 5200]

export function TerminalDemo({ demo }: { demo: Dictionary["demo"] }) {
  const s = useTimeline(timeline)

  const agentOpen = s >= 3
  const diffOpen = s >= 6
  const focus = s >= 3 ? "agent" : "shell"

  return (
    <TerminalWindow>
        <div className="grid h-[560px] grid-rows-[1fr_auto] gap-0 font-mono text-[11.5px] leading-relaxed sm:h-[380px] sm:text-xs">
          <motion.div layout className={cn("grid min-h-0 gap-1.5 p-1.5", agentOpen ? "grid-cols-1 grid-rows-[auto_1fr] sm:grid-cols-2 sm:grid-rows-1" : "grid-cols-1")}>
            <Pane title="shell" active={focus === "shell"}>
              <Prompt text="work" typing={s === 0} done={s >= 1} caret={s === 0} />
              {s >= 1 && (
                <Line className="text-ctp-overlay1">
                  {demo.session} <span className="text-ctp-mauve">work</span> · {demo.windows}
                </Line>
              )}
              {s >= 2 && <Line className="text-ctp-overlay1">{demo.agentHint}</Line>}
              {diffOpen && <Line className="text-ctp-overlay1">{demo.diffHint}</Line>}
            </Pane>

            <AnimatePresence>
              {agentOpen && (
                <motion.div key="ia" layout className={cn("grid min-h-0 gap-1.5", diffOpen ? "grid-rows-[1fr_auto]" : "grid-rows-1")}>
                  <Pane title={demo.agentPane} active={focus === "agent"}>
                    <Line>
                      <span className="text-ctp-peach">› </span>
                      <span className="text-ctp-text">{demo.prompt}</span>
                    </Line>
                    {s >= 4 && (
                      <>
                        <Line className="text-ctp-subtext0" delay={0.1}>  {demo.reading} src/auth/login.ts</Line>
                        <Line className="text-ctp-subtext0" delay={0.5}>  {demo.creating} src/auth/email.ts</Line>
                        <Line className="text-ctp-subtext0" delay={0.9}>  {demo.editing} src/auth/login.ts</Line>
                      </>
                    )}
                    {s >= 5 && <Line className="text-ctp-green">  {demo.done}</Line>}
                    {s >= 7 && <Line><span className="text-ctp-peach">› </span><span className="text-ctp-text">{s >= 8 ? "/code-review" : <Typed text="/code-review" />}</span><Caret show={s === 7} /></Line>}
                    {s >= 8 && <Line className="mt-1 text-ctp-text" delay={0.05}>  {demo.reviewFound}</Line>}
                    {s >= 9 && <Line className="text-ctp-subtext0" delay={0.05}>  email.ts:3   <span className="text-ctp-text">{demo.issueEmail}</span></Line>}
                    {s >= 10 && <Line className="text-ctp-subtext0" delay={0.05}>  login.ts:13  <span className="text-ctp-text">{demo.issueTest}</span></Line>}
                  </Pane>
                  <AnimatePresence>
                    {diffOpen && (
                      <motion.div key="diff" layout initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }}>
                        <Pane title={demo.diffPane} active={false}>
                          <Line className="text-ctp-overlay1">{demo.diffSummary} <span className="text-ctp-green">+18</span> <span className="text-ctp-red">-2</span></Line>
                          <Line className="text-ctp-subtext0" delay={0.1}>  src/auth/email.ts  <span className="text-ctp-green">+14</span></Line>
                          <Line className="text-ctp-subtext0" delay={0.2}>  src/auth/login.ts  <span className="text-ctp-green">+4</span> <span className="text-ctp-red">-2</span></Line>
                        </Pane>
                      </motion.div>
                    )}
                  </AnimatePresence>
                </motion.div>
              )}
            </AnimatePresence>
          </motion.div>

          <StatusBar windows={["painel", "api", "web", "notas"]} active={2} starred={s === 5 ? 2 : undefined} branch="feature/login" />
        </div>
    </TerminalWindow>
  )
}
