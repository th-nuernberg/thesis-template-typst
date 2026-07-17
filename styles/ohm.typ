/*
 * Ohm-Doc Typst Styles
 *
 * Copyright (c) 2026 Nils Weber <me@vimkat.dev>
 *
 * This template is based on the original LaTeX template by Marvin Fette (see https://github.com/th-nuernberg/thesis-template-latex)
 * Please read the README.md for instructions and how to use this template.
 *
 * Changelog:
 *
 * 1.0.0 (2026/XX/XX) Initial release
 */

#import "@preview/glossarium:0.5.10": make-glossary, register-glossary, print-glossary, gls, glspl

#let _type = type
#let ex = 5pt

#let thesis-parameters = state("thesis-parameters")
#let p(key, default: none, map: v => v) = {
  let value = thesis-parameters.get().at(key, default: default)
  return map(value)
}

#let translations = (
  "de": (
    "at_uni": "an der Technischen Hochschule Nürnberg",
    "bachelor": "Bachelorarbeit",
    "master": "Masterarbeit",
    "report": "Bericht",
    "faculty": "Fakultät Informatik",
    "student-id": "Matrikelnummer",
    "examiners-singular": "Prüfer",
    "examiners-plural": "Prüfer",
    "supervisors-singular": "Betreuer",
    "supervisors-plural": "Betreuer",
    "copyright": context [
      #let company = thesis-parameters.get().at("company", default: none)
      #let copyright = if company != none [von #company] else [des Urhebers]
      Diese Arbeit, einschließlich ihrer Teile, *ist urheberrechtlich geschützt*.
      Jede Verwertung außerhalb der engen Grenzen des Urheberrechtsgesetzes ohne Zustimmung #copyright ist untersagt und strafbar.
      Dies gilt insbesondere für Vervielfältigungen, Übersetzungen, Mikroverfilmung und die Speicherung und Verarbeitung in elektronischen Systemen.
    ],
    "TOC": "Inhaltsverzeichnis",
    "LOT": "Tabellenverzeichnis",
    "LOF": "Abbildungsverzeichnis",
    "LOL": "Quellcodeverzeichnis",
    "LOA": "Abkürzungsverzeichnis",
    "BIB": "Referenzen",
    "glossary": "Glossar",
    "chapter": "Kapitel",
    "section": "Abschnitt",
    "appendix": "Anhang",
    "ack": "Danksagung",
    "abstract": "Kurzdarstellung",
    "kurzdarstellung": "Abstract",
  ),
  "de-gender": (
    "examiners-singular": "Prüfer*in",
    "examiners-plural": "Prüfer*innen",
    "supervisors-singular": "Betreuer*in",
    "supervisors-plural": "Betreuer*innen",
    "copyright": context [
      #let company = thesis-parameters.get().at("company", default: none)
      #let copyright = if company != none { company } else { thesis-parameters.get().at("author") }
      Diese Arbeit, einschließlich ihrer Teile, *ist urheberrechtlich geschützt*.
      Jede Verwertung außerhalb der engen Grenzen des Urheberrechtsgesetzes ohne Zustimmung von #copyright ist untersagt und strafbar.
      Dies gilt insbesondere für Vervielfältigungen, Übersetzungen, Mikroverfilmung und die Speicherung und Verarbeitung in elektronischen Systemen.
    ],
  ),
  "en": (
    "at_uni": "at Nuremberg Institute of Technology",
    "bachelor": "Bachelor Thesis",
    "master": "Master Thesis",
    "report": "Report",
    "faculty": "Faculty of Computer Science",
    "student-id": "Student ID",
    "examiners-singular": "Examiner",
    "examiners-plural": "Examiners",
    "supervisors-singular": "Supervisor",
    "supervisors-plural": "Supervisors",
    "copyright": context [
      #let company = thesis-parameters.get().at("company", default: none)
      #let copyright = if company != none { company } else [the author]
      This work, including its parts, *is protected by copyright*.
      Any use outside the narrow limits of copyright law without the consent of #copyright is prohibited and punishable by law.
      This applies in particular to reproductions, translations, microfilming and storage and processing in electronic systems.
    ],
    "TOC": "Table of Contents",
    "LOT": "List of Tables",
    "LOF": "List of Figures",
    "LOL": "List of Listings",
    "LOA": "List of Acronyms",
    "BIB": "References",
    "glossary": "Glossary",
    "chapter": "Chapter",
    "section": "Section",
    "appendix": "Appendix",
    "ack": "Acknowledgements",
    "abstract": "Abstract",
    "kurzdarstellung": "Kurzdarstellung",
  ),
)

#let t(key, default: none) = {
  let locale = p("lang")
  let locale-fallback = locale.split("-").at(0)

  return translations.at(locale).at(key, default: translations.at(locale-fallback).at(key, default: default))
}

#let normalize-multivalue(value) = {
  if value == none { return none }
  if type(value) == array { return value }
  return (value,)
}

#let to-glossary-entries(dict) = dict.pairs().map(e => (key: e.at(0), ..e.at(1).map(s => eval(s, mode: "markup"))))

#let frontmatter-heading = heading.with(numbering: none, outlined: false, bookmarked: true)
#let outline-loX(..args) = {
  show outline.entry: it => link(it.element.location(), it.indented(it.element.counter.display(at: it.element.location()), it.inner()))
  outline(title: none, ..args)
}

#let heading-number(c) = {
  if c.numbering == none { return none }
  return numbering(c.numbering,..counter(heading).at(c.location()))
}

#let current-heading(level: 1) = {
  let before = query(selector(heading.where(level: level)).before(here()))
  before = if before.len() > 0 { before.last() } else { none }
  let after = query(selector(heading.where(level: level)).after(here()))
  after = if after.len() > 0 { after.first() } else { none }

  if level == 1 {
    let isChapterPage = after != none and after.location().page() == here().page() or after == none and before != none and before.location().page() == here().page()
    if not isChapterPage and before != none { return before }
    return none
  } else {
    let chap = current-heading()
    if chap == none or before == none { return none }
    let chap-num = counter(heading).at(chap.location()).at(0)
    let heading-chap-num = counter(heading).at(before.location()).at(0)
    if chap-num == heading-chap-num { return before }
  }
}


#let thesis-titlepage() = context {
  pagebreak(weak: true)
  set page(numbering: none)
  set align(center)

  let examiners = normalize-multivalue(p("examiners"))
  let supervisors = normalize-multivalue(p("supervisors"))

  text(size: 8pt)[#t("faculty") #t("at_uni") #t("university")]
  v(6 * ex)
  image("ohm-logo.svg", width: 90%)
  v(6 * ex)
  text(size: 14.4pt, p("type", map: t))
  v(8 * ex)
  text(size: 20.74pt, p("title"))
  v(8 * ex)
  text(size: 14.4pt, p("author"))
  if p("student-id", default: none) != none {
    [\ #t("student-id"): #p("student-id")]
  }
  v(8 * ex)
  text(size: 12pt, grid(
    columns: (auto, auto),
    row-gutter: 1.6em,
    column-gutter: 1em,
    align: (right, left),
    ..if examiners != none { (if examiners.len() == 1 [#t("examiners-singular"):] else [#t("examiners-plural"):], stack(spacing: 0.65em, ..examiners)) },
    ..if supervisors != none { (if supervisors.len() == 1 [#t("supervisors-singular"):] else [#t("supervisors-plural"):], stack(spacing: 0.65em, ..supervisors, p("company"))) },
  ))
  v(1fr)
  text(size: 8pt)[
    #let company = p("company")
    #let copyright = if company != none { company } else { p("author") }
    #sym.copyright #copyright #p("date", map: d => d.year())
    #v(2 * ex)
    #align(left, t("copyright"))
  ]
  pagebreak(weak: true)
}

#let thesis-acknowledgements() = context {
  if p("acknowledgements") != none {
    frontmatter-heading(numbering: none, t("ack"))
    p("acknowledgements")
  }
}

#let thesis-abstract() = context {
  frontmatter-heading(numbering: none, t("abstract"))
  let abstract = p("abstract")
  abstract.main

  let keywords = normalize-multivalue(p("keywords"))
  if keywords != none and keywords.len() > 0 {
    frontmatter-heading(numbering: none, depth: 2)[Keywords]
    keywords.join([, ])
  }
  if abstract.alt != none {
    pagebreak(weak: true)
    frontmatter-heading(numbering: none, depth: 1, t("kurzdarstellung"))
    abstract.alt
  }
}

#let thesis-toc() = context {
  frontmatter-heading(t("TOC"))

  show outline.entry.where(level: 1): set outline.entry(fill: none)
  show outline.entry.where(level: 1): it => {
    set text(weight: "bold")
    set block(above: 2em)
    it
  }
  block(above: 0em, outline(title: none, depth: 3))
}

#let thesis-lof() = context {
  frontmatter-heading(t("LOF"))
  outline-loX(target: figure.where(kind: image))
}

#let thesis-lot() = context {
  frontmatter-heading(t("LOT"))
  outline-loX(target: figure.where(kind: table))
}

#let thesis-lol() = context {
  frontmatter-heading(t("LOL"))
  outline-loX(target: figure.where(kind: raw))
}

#let thesis-loa() = context {
  let entries = p("glossary")
  if entries != none and entries.at("acronyms", default: none) != none {
    frontmatter-heading(t("LOA"))
    print-glossary(to-glossary-entries(entries.acronyms))
  }
}

#let thesis-glossary() = context {
  let entries = p("glossary")
  if entries != none and entries.at("glossary", default: none) != none {
    frontmatter-heading(t("glossary"))
    print-glossary(to-glossary-entries(entries.glossary))
  }
}

#let thesis-bibliography() = context {
  let bib-file = p("bibliography-file")
  let bib-style = p("bibliography-style")

  if bib-file != none {
    frontmatter-heading(t("BIB"))
    bibliography(
      "../" + bib-file,
      title: none,
      style: if bib-style == "alphanumeric" { "ieee" } else { bib-style },
    )
  }
}

#let appendix-content = state("appendix-content")
#let appendix(body) = { appendix-content.update(body) }
#let thesis-appendix() = context {
  show heading.where(level: 1): set heading(supplement: context t("appendix"))
  set heading(numbering: "A.1")
  counter(heading).update(0)

  appendix-content.get()
}

#let thesis(
  /// Title of the thesis or report.
  title: none,

  /// Author of this thesis or report.
  author: none,

  /// Student ID printed below the author if given.
  student-id: none,

  /// Date of this work, defaults to today.
  date: datetime.today(),

  /// Bibliography to use for this document.
  bibliography-file: none,

  /// Citation standard to use, see https://typst.app/docs/reference/model/bibliography for a full list. Alphanumeric is supported.
  bibliography-style: "ieee",

  /// Type of this thesis, can be "bachelor", "master" or "report".
  type: none,

  /// Language of this document, only "de", "en" are fully supported.
  lang: none,

  /// Whether to layout the document as a book (that can be bound) or not.
  book: false,

  /// Data to include in the header. Can be 'none' (empty), '"chapter"' (only current chapter), '"full"' (current chapter and section) or custom content.
  header: "chapter",

  /// Thesis abstract. To use multiple languages, use a dictionary with the language as the key.
  abstract: none,

  /// Additional acknowledgements added to the beginning.
  acknowledgements: none,

  /// Name of the examiner or list of names if multiple examiners.
  examiners: none,

  /// Name of the supervisor or list of names if multiple supervisors.
  supervisors: none,

  /// List of keywords for the title page.
  keywords: none,

  /// URL to a repository with additional references or content, e.g. a Git repository.
  repository: none,

  /// Company that supported this thesis.
  company: none,

  /// Entries for acronyms and glossary (Hint: Use a separate data file to define them).
  glossary: none,

  /// Don't emit any parts of the document itself, only set the styling options. Structure can be set up manually using the thesis-* functions.
  manual: false,

  /// Enable debug mode that shows errors within the document.
  debug: false,

  /// Thesis content, use as global show rule is encouraged.
  body,
) = {
  // Validate parameters
  if not ("bachelor", "master", "report").contains(type) {
    panic("Set either 'bachelor', 'master', or 'report' as the document type option")
  }
  let lang-base = lang.split("-").at(0)
  if not ("de", "en").contains(lang-base) {
    panic("Set either 'de' or 'en' as the document language")
  }

  // Convert multilingual abstract into main/alt abstract
  if lang-base == "en" and (_type(abstract) != dictionary or abstract.at("de", default: none) == none) {
    panic("Kurzdarstellung required for English language")
  }
  let abstract-semantic = if _type(abstract) != dictionary {
    (main: abstract, alt: none)
  } else if lang-base == "de" {
    (main: abstract.de, alt: abstract.en)
  } else {
    (main: abstract.en, alt: abstract.de)
  }

  // All function parameters to be used in the thesis-* functions
  thesis-parameters.update((
    title: title,
    author: author,
    student-id: student-id,
    date: date,
    bibliography-file: bibliography-file,
    bibliography-style: bibliography-style,
    type: type,
    lang: lang,
    book: book,
    abstract: abstract-semantic,
    acknowledgements: acknowledgements,
    supervisors: supervisors,
    examiners: examiners,
    keywords: keywords,
    repository: repository,
    company: company,
    glossary: glossary,
    manual: manual,
    debug: debug,
  ))


  // Set document properties if given
  if title != none { set document(title: title) }
  if author != none { set document(author: author) }
  if abstract-semantic.main != none { set document(description: abstract-semantic.main) }
  if keywords != none { set document(keywords: keywords) }

  set page(
    paper: "a4",
    margin: (x: 2.75cm, y: 3.5cm),
    numbering: "1",
    header: context {
      if _type(header) == str and ("chapter", "full").contains(header) {
        let chap = current-heading()
        let sec = if header == "full" { current-heading(level: 2) } else { none }
        set text(style: "italic")
        show: upper

        grid(
          columns: (auto, 1fr, auto),
          align: (left, right),
          if sec != none [#heading-number(sec). #h(0.75em) #sec.body],
          if chap != none {
            if chap.numbering != none [#chap.supplement #heading-number(chap).#h(0.75em)]
            chap.body
          },
        )
      }
      else if header == none { none }
      else { header }
    }
  )

  set text(
    lang: lang-base,
    font: "New Computer Modern",
    weight: "medium",
    size: 10pt,
  )
  set par(
    justify: true,
  )

  // Register all entries
  show: make-glossary
  if glossary != none {
    let entries = (
      to-glossary-entries(glossary.acronyms),
      to-glossary-entries(glossary.glossary),
    ).flatten()
    register-glossary(entries)
  }

  // Show rules for common abbreviations
  let nnbsp = [\u{202F}]
  show regex("z\.\s?B\."):       [z.\u{202F}B.]
  show regex("u\.\s?a\."):       [u.\u{202F}a.]
  show regex("d\.\s?h\."):       [d.\u{202F}h.]
  show regex("e\.\s?g\."):       [e.\u{FEFF}g.]
  show regex("i\.\s?e\."):       [i.\u{FEFF}e.]
  show regex("w\.\s?r\.\s?t\."): [w.\u{FEFF}r.\u{FEFF}t.]

  set heading(supplement: context t("section"))
  show heading.where(level: 1): set heading(supplement: context t("chapter"), numbering: "1.1")
  show heading.where(level: 1): it => {
    set text(size: 24.88pt, weight: "medium")
    set par(leading: 0.5em, justify: false)
    pagebreak(weak: true)
    v(16*ex)
    if it.numbering != none {
      stack(spacing: 8*ex, text(size: 0.85em)[#it.supplement #heading-number(it)], it.body)
    } else {
      it.body
    }
    v(4*ex)

    // Counter reset for figure counters that are <chapter>.1..
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)
  }
  show heading.where(level: 2): set heading(numbering: "1.1")
  show heading.where(level: 3): set heading(numbering: "1.1")

  set figure(numbering: (..num) =>
    numbering("1.1", counter(heading).get().first(), num.pos().first())
  )
  show figure: it => {
    set align(center)
    set block(spacing: 2em)
    it
  }
  show figure.caption: it => {
    v(0.5em)
    it
  }

  set table(stroke: none)
  set table.hline(stroke: 0.75pt)

  // Alphanumeric is a citation style, not a bibliography style.
  set cite(style: "alphanumeric") if bibliography-style == "alphanumeric"

  // Print document structure or nothing (user has to set it up manually)
  if not manual {
    set page(numbering: "i")
    thesis-titlepage()
    thesis-acknowledgements()
    thesis-abstract()
    thesis-toc()
    thesis-loa()

    pagebreak(weak: true)
    counter(page).update(1)
    set page(numbering: "1")
    body

    thesis-lof()
    thesis-lol()
    thesis-lot()

    thesis-glossary()
    thesis-bibliography()
    thesis-appendix()
  } else {
    body
  }
}
