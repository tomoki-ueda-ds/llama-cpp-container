#!/usr/bin/env python3

"""
chat.py

Interactive terminal client for llama-server.

Features
--------
- OpenAI Compatible API
- Rich Markdown rendering
- Streaming generation
- Session save/load
- Conversation history
- PromptToolkit
"""

from __future__ import annotations

import json
import os
import signal
import sys
import time
import uuid
from dataclasses import dataclass, asdict
from datetime import datetime
from pathlib import Path
from typing import List

from openai import OpenAI

from rich.console import Console
from rich.markdown import Markdown
from rich.panel import Panel
from rich.syntax import Syntax
from rich.table import Table

from prompt_toolkit import PromptSession
from prompt_toolkit.history import FileHistory

###############################################################################
# Paths
###############################################################################

APP_DIR = Path.home() / ".local/share/llama-cpp-container"

SESSION_DIR = APP_DIR / "sessions"

APP_DIR.mkdir(parents=True, exist_ok=True)

SESSION_DIR.mkdir(parents=True, exist_ok=True)

HISTORY_FILE = APP_DIR / "history.txt"

###############################################################################
# Console
###############################################################################

console = Console()

###############################################################################
# OpenAI Client
###############################################################################

client = OpenAI(
    api_key=os.environ["OPENAI_API_KEY"],
    base_url=os.environ["OPENAI_API_BASE"],
)

MODEL = os.environ.get("MODEL_ALIAS", "model")

###############################################################################
# Data structures
###############################################################################

@dataclass
class ChatMessage:

    role: str

    content: str


@dataclass
class ChatSession:

    title: str

    created: str

    model: str

    system_prompt: str

    messages: List[ChatMessage]

###############################################################################
# Globals
###############################################################################

system_prompt = "You are a helpful assistant."

messages: List[ChatMessage] = []

current_title = "Untitled"

###############################################################################
# Utilities
###############################################################################

def now():

    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def session_filename(title: str):

    safe = title.replace(" ", "_")

    return SESSION_DIR / f"{safe}.json"


###############################################################################
# Save session
###############################################################################

def save_session(title=None):

    global current_title

    if title:

        current_title = title

    session = ChatSession(
        title=current_title,
        created=now(),
        model=MODEL,
        system_prompt=system_prompt,
        messages=messages,
    )

    path = session_filename(current_title)

    with open(path, "w", encoding="utf-8") as f:

        json.dump(
            {
                "title": session.title,
                "created": session.created,
                "model": session.model,
                "system_prompt": session.system_prompt,
                "messages": [
                    asdict(m)
                    for m in session.messages
                ],
            },
            f,
            indent=2,
            ensure_ascii=False,
        )

    console.print(
        f"[green]Saved:[/green] {path}"
    )

###############################################################################
# Load session
###############################################################################

def load_session(title):

    global current_title

    global system_prompt

    global messages

    path = session_filename(title)

    if not path.exists():

        console.print(
            f"[red]Session not found:[/red] {title}"
        )

        return

    with open(path, encoding="utf-8") as f:

        data = json.load(f)

    current_title = data["title"]

    system_prompt = data["system_prompt"]

    messages = [
        ChatMessage(**m)
        for m in data["messages"]
    ]

    console.print(
        f"[green]Loaded:[/green] {current_title}"
    )

###############################################################################
# Session list
###############################################################################

def list_sessions():

    table = Table(title="Sessions")

    table.add_column("Title")

    table.add_column("Modified")

    files = sorted(
        SESSION_DIR.glob("*.json")
    )

    for file in files:

        table.add_row(
            file.stem,
            datetime.fromtimestamp(
                file.stat().st_mtime
            ).strftime("%Y-%m-%d %H:%M"),
        )

    console.print(table)

###############################################################################
# Banner
###############################################################################

def banner():

    console.print()

    console.print(
        Panel.fit(
            f"[bold cyan]{MODEL}[/bold cyan]\n"
            "Interactive Chat",
            border_style="cyan",
        )
    )

    console.print(
        "[dim]"
        "/help  "
        "/save  "
        "/load  "
        "/history  "
        "/system  "
        "/clear  "
        "/exit"
        "[/dim]"
    )

###############################################################################
# Prompt Toolkit
###############################################################################

prompt = PromptSession(
    history=FileHistory(
        str(HISTORY_FILE)
    )
)

###############################################################################
# Ctrl+C handling
###############################################################################

interrupt_generation = False

def signal_handler(sig, frame):

    global interrupt_generation

    interrupt_generation = True

signal.signal(
    signal.SIGINT,
    signal_handler,
)

###############################################################################
# Markdown rendering
###############################################################################

def render_markdown(text: str):

    """
    Render assistant output using Rich Markdown.
    Code blocks are automatically syntax highlighted.
    """

    console.print()

    console.print(
        Panel.fit(
            "Assistant",
            border_style="cyan",
        )
    )

    console.print(
        Markdown(text)
    )

###############################################################################
# Statistics
###############################################################################

last_prompt_tokens = 0
last_completion_tokens = 0
last_elapsed = 0.0
last_tps = 0.0

###############################################################################
# Streaming generation
###############################################################################

def chat_stream(prompt_text: str):

    global interrupt_generation
    global last_prompt_tokens
    global last_completion_tokens
    global last_elapsed
    global last_tps

    interrupt_generation = False

    request = []

    request.append(
        {
            "role": "system",
            "content": system_prompt,
        }
    )

    for m in messages:

        request.append(
            {
                "role": m.role,
                "content": m.content,
            }
        )

    request.append(
        {
            "role": "user",
            "content": prompt_text,
        }
    )

    console.print()

    console.print(
        "[bold cyan]Assistant[/bold cyan]"
    )

    stream = client.chat.completions.create(
        model=MODEL,
        messages=request,
        stream=True,
    )

    start = time.time()

    answer = ""

    generated_tokens = 0

    try:

        for chunk in stream:

            if interrupt_generation:

                console.print()

                console.print(
                    "[yellow]Generation interrupted.[/yellow]"
                )

                break

            delta = chunk.choices[0].delta

            if delta.content:

                token = delta.content

                answer += token

                generated_tokens += 1

                print(
                    token,
                    end="",
                    flush=True,
                )

    finally:

        elapsed = time.time() - start

    print()

    if answer.strip():

        messages.append(
            ChatMessage(
                role="user",
                content=prompt_text,
            )
        )

        messages.append(
            ChatMessage(
                role="assistant",
                content=answer,
            )
        )

    last_completion_tokens = generated_tokens

    last_elapsed = elapsed

    if elapsed > 0:

        last_tps = generated_tokens / elapsed

    else:

        last_tps = 0

    console.print()

    console.print(
        "[dim]"
        f"{generated_tokens} tokens | "
        f"{elapsed:.2f} sec | "
        f"{last_tps:.1f} tok/sec"
        "[/dim]"
    )

    #######################################################################
    # Pretty render
    #######################################################################

    console.rule()

    render_markdown(answer)

###############################################################################
# Commands
###############################################################################

def command_help():

    table = Table(title="Commands")

    table.add_column("Command")

    table.add_column("Description")

    table.add_row("/help","Show help")

    table.add_row("/save","Save session")

    table.add_row("/load","Load session")

    table.add_row("/history","List sessions")

    table.add_row("/models","List server models")

    table.add_row("/clear","Clear conversation")

    table.add_row("/system","Change system prompt")

    table.add_row("/stats","Generation statistics")

    table.add_row("/tokens","Token statistics")

    table.add_row("/exit","Exit")

    console.print(table)

###############################################################################
# /models
###############################################################################

def command_models():

    console.print()

    try:

        models = client.models.list()

    except Exception as e:

        console.print(e)

        return

    table = Table(title="Available Models")

    table.add_column("Model")

    for model in models.data:

        table.add_row(model.id)

    console.print(table)

###############################################################################
# /tokens
###############################################################################

def command_tokens():

    table = Table(title="Token Usage")

    table.add_column("Item")

    table.add_column("Value")

    table.add_row(
        "Completion",
        str(last_completion_tokens),
    )

    table.add_row(
        "Speed",
        f"{last_tps:.1f} tok/sec",
    )

    console.print(table)

###############################################################################
# /stats
###############################################################################

def command_stats():

    table = Table(title="Statistics")

    table.add_column("Metric")

    table.add_column("Value")

    table.add_row(
        "Messages",
        str(len(messages)),
    )

    table.add_row(
        "Elapsed",
        f"{last_elapsed:.2f} sec",
    )

    table.add_row(
        "Completion Tokens",
        str(last_completion_tokens),
    )

    table.add_row(
        "Generation Speed",
        f"{last_tps:.1f} tok/sec",
    )

    table.add_row(
        "Current Session",
        current_title,
    )

    console.print(table)

###############################################################################
# /clear
###############################################################################

def command_clear():

    global messages

    messages = []

    console.print(
        "[green]Conversation cleared.[/green]"
    )

###############################################################################
# /system
###############################################################################

def command_system():

    global system_prompt

    console.print()

    console.print(
        "[bold]Current system prompt[/bold]"
    )

    console.print(system_prompt)

    console.print()

    console.print(
        "New prompt (blank = cancel)"
    )

    new_prompt = input("> ").strip()

    if not new_prompt:

        console.print(
            "[yellow]Cancelled.[/yellow]"
        )

        return

    system_prompt = new_prompt

    console.print(
        "[green]Updated.[/green]"
    )

###############################################################################
# Session title
###############################################################################

def auto_title():

    """
    Generate simple title from first user message.
    """

    for msg in messages:

        if msg.role == "user":

            title = msg.content.strip()

            title = title.replace("/", "_")

            if len(title) > 40:

                title = title[:40]

            return title

    return f"session-{uuid.uuid4().hex[:8]}"


###############################################################################
# Command dispatcher
###############################################################################

def handle_command(line: str):

    global current_title

    args = line.strip().split()

    cmd = args[0]

    ###########################################################################

    if cmd == "/help":

        command_help()

        return True

    ###########################################################################

    if cmd == "/history":

        list_sessions()

        return True

    ###########################################################################

    if cmd == "/models":

        command_models()

        return True

    ###########################################################################

    if cmd == "/tokens":

        command_tokens()

        return True

    ###########################################################################

    if cmd == "/stats":

        command_stats()

        return True

    ###########################################################################

    if cmd == "/clear":

        command_clear()

        return True

    ###########################################################################

    if cmd == "/system":

        command_system()

        return True

    ###########################################################################

    if cmd == "/save":

        if len(args) >= 2:

            current_title = " ".join(args[1:])

        elif current_title == "Untitled":

            current_title = auto_title()

        save_session(current_title)

        return True

    ###########################################################################

    if cmd == "/load":

        if len(args) != 2:

            console.print()

            console.print(
                "Usage: /load SESSION_NAME"
            )

            return True

        load_session(args[1])

        return True

    ###########################################################################

    if cmd == "/exit":

        raise EOFError

    ###########################################################################

    console.print()

    console.print(
        "[red]Unknown command[/red]"
    )

    return True


###############################################################################
# Chat loop
###############################################################################

def repl():

    banner()

    while True:

        try:

            text = prompt.prompt(
                "[bold green]You> [/bold green]"
            )

        except EOFError:

            console.print()

            console.print(
                "[cyan]Bye![/cyan]"
            )

            break

        except KeyboardInterrupt:

            console.print()

            continue

        #######################################################################

        text = text.strip()

        if not text:

            continue

        #######################################################################

        if text.startswith("/"):

            try:

                handle_command(text)

            except EOFError:

                console.print()

                console.print(
                    "[cyan]Bye![/cyan]"
                )

                break

            continue

        #######################################################################

        chat_stream(text)


###############################################################################
# Entry point
###############################################################################

def main():

    console.print()

    console.print(
        Panel.fit(
            "[bold cyan]llama.cpp Terminal Chat[/bold cyan]",
            border_style="cyan",
        )
    )

    console.print(
        f"[dim]Model : {MODEL}[/dim]"
    )

    console.print(
        f"[dim]API   : {os.environ['OPENAI_API_BASE']}[/dim]"
    )

    console.print()

    try:

        client.models.list()

    except Exception as e:

        console.print()

        console.print(
            "[red]Unable to connect to llama-server[/red]"
        )

        console.print(e)

        sys.exit(1)

    repl()


###############################################################################

if __name__ == "__main__":

    main()


###############################################################################
# Auto save
###############################################################################

AUTO_SAVE = True


def auto_save():

    if not AUTO_SAVE:
        return

    if not messages:
        return

    title = current_title

    if title == "Untitled":
        title = auto_title()

    save_session(title)


###############################################################################
# Delete session
###############################################################################

def delete_session(title):

    path = session_filename(title)

    if not path.exists():

        console.print("[red]Session not found[/red]")

        return

    path.unlink()

    console.print(f"[green]Deleted[/green] {title}")


###############################################################################
# Rename session
###############################################################################

def rename_session(old, new):

    old_path = session_filename(old)

    new_path = session_filename(new)

    if not old_path.exists():

        console.print("[red]Session not found[/red]")

        return

    old_path.rename(new_path)

    console.print(f"[green]{old} -> {new}[/green]")


###############################################################################
# Export Markdown
###############################################################################

def export_markdown(title):

    path = session_filename(title)

    if not path.exists():

        console.print("[red]Session not found[/red]")

        return

    with open(path, encoding="utf8") as f:

        data = json.load(f)

    md = []

    md.append(f"# {data['title']}\n")

    md.append(f"Generated: {data['created']}\n")

    md.append("---\n")

    md.append("## System\n")

    md.append(data["system_prompt"])

    md.append("\n")

    for m in data["messages"]:

        md.append(f"## {m['role'].capitalize()}")

        md.append("")

        md.append(m["content"])

        md.append("")

    outfile = SESSION_DIR / f"{title}.md"

    outfile.write_text(
        "\n".join(md),
        encoding="utf8",
    )

    console.print(
        f"[green]Exported[/green] {outfile}"
    )


###############################################################################
# Export JSON
###############################################################################

def export_json(title):

    src = session_filename(title)

    dst = SESSION_DIR / f"{title}.export.json"

    if not src.exists():

        console.print("[red]Session not found[/red]")

        return

    shutil.copy(src, dst)

    console.print(
        f"[green]Exported[/green] {dst}"
    )


###############################################################################
# Context statistics
###############################################################################

def context_statistics():

    total_chars = 0

    total_messages = len(messages)

    for m in messages:

        total_chars += len(m.content)

    table = Table(title="Conversation")

    table.add_column("Metric")

    table.add_column("Value")

    table.add_row(
        "Messages",
        str(total_messages),
    )

    table.add_row(
        "Characters",
        str(total_chars),
    )

    table.add_row(
        "Approx Tokens",
        str(total_chars // 4),
    )

    console.print(table)


###############################################################################
# Better title generation
###############################################################################

def generate_title():

    if len(messages) < 2:

        return auto_title()

    try:

        response = client.chat.completions.create(

            model=MODEL,

            messages=[

                {
                    "role":"system",
                    "content":"Generate a short session title (<=6 words). Output title only."
                },

                {
                    "role":"user",
                    "content":messages[0].content
                }

            ],

            temperature=0,

        )

        title = response.choices[0].message.content.strip()

        title = title.replace("/","_")

        return title

    except Exception:

        return auto_title()


###############################################################################
# Markdown export helper
###############################################################################

def pretty_print_last():

    if not messages:

        return

    msg = messages[-1]

    if msg.role != "assistant":

        return

    console.rule()

    console.print(
        Markdown(msg.content)
    )


###############################################################################
# Conversation summary
###############################################################################

def summarize():

    if len(messages) < 4:

        return

    try:

        response = client.chat.completions.create(

            model=MODEL,

            messages=[

                {
                    "role":"system",
                    "content":"Summarize this conversation in under 200 words."
                }

            ] + [

                {
                    "role":m.role,
                    "content":m.content
                }

                for m in messages

            ]

        )

        console.print()

        console.print(
            Panel(
                Markdown(
                    response.choices[0].message.content
                ),
                title="Summary",
            )
        )

    except Exception as e:

        console.print(e)


###############################################################################
# Add to handle_command()
###############################################################################

# /rename OLD NEW
#
# rename_session(args[1], args[2])

# /delete NAME
#
# delete_session(args[1])

# /summary
#
# summarize()

# /export NAME
#
# export_markdown(args[1])

# /context
#
# context_statistics()


###############################################################################
# Before exiting repl()
###############################################################################

auto_save()

###############################################################################
# End of file
###############################################################################