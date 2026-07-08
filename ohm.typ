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
    "BIB": "Referenzen",
    "chapter": "Kapitel",
    "section": "Abschnitt",
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
    "BIB": "References",
    "chapter": "Chapter",
    "section": "Section",
    "abstract": "Abstract",
    "kurzdarstellung": "Kurzdarstellung",
  ),
)

#let t(key, default: none) = context {
  let locale = thesis-parameters.get().lang
  let locale-fallback = locale.split("-").at(0)

  return translations.at(locale).at(key, default: translations.at(locale-fallback).at(key, default: default))
}

#let normalize-multivalue(value) = {
  if value == none { return none }
  if type(value) == array { return value }
  return (value,)
}

#let thesis-titlepage() = context {
  pagebreak(weak: true)
  set page(numbering: none)
  set align(center)

  let examiners = normalize-multivalue(p("examiners"))
  let supervisors = normalize-multivalue(p("supervisors"))

  text(size: 8pt)[#t("faculty") #t("at_uni") #t("university")]
  v(6 * ex)
  image("assets/ohm-logo.svg", width: 90%)
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

#let thesis-abstract() = context {
  pagebreak(weak: true)
  set page(numbering: "i")

  heading(numbering: none, t("abstract"))
  let abstract = p("abstract")
  abstract.main

  let keywords = normalize-multivalue(p("keywords"))
  if keywords != none and keywords.len() > 0 {
    heading(numbering: none, depth: 2)[Keywords]
    keywords.join([, ])
  }
  if abstract.alt != none {
    pagebreak(weak: true)
    heading(numbering: none, depth: 2, t("kurzdarstellung"))
    abstract.alt
  }
}

#let thesis-start() = {
  pagebreak(weak: true)
  counter(page).update(1)
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

  /// Citation standard to use, see https://typst.app/docs/reference/model/bibliography for a full list.
  bibliography-style: none,

  /// Type of this thesis, can be "bachelor", "master" or "report".
  type: none,

  /// Language of this document, only "de", "en" are fully supported.
  lang: none,

  /// Whether to layout the document as a book (that can be bound) or not.
  book: false,

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
  )

  set text(
    lang: lang-base,
    font: "New Computer Modern",
    weight: "medium",
  )

  // Show rules for common abbreviations

  let nnbsp = [\u{202F}]
  show regex("z\.\s?B\."):       [z.\u{202F}B.]
  show regex("u\.\s?a\."):       [u.\u{202F}a.]
  show regex("d\.\s?h\."):       [d.\u{202F}h.]
  show regex("e\.\s?g\."):       [e.\u{FEFF}g.]
  show regex("i\.\s?e\."):       [i.\u{FEFF}e.]
  show regex("w\.\s?r\.\s?t\."): [w.\u{FEFF}r.\u{FEFF}t.]

  set heading(numbering: "1.1", supplement: t("section"))
  show heading.where(level: 1): set heading(supplement: t("chapter"))
  show heading.where(level: 1): it => {
    set text(size: 24.88pt, weight: "medium")
    pagebreak(weak: true)
    pad(
      top: 16*ex,
      bottom: 8*ex,
      if it.numbering != none {
        stack(spacing: 8*ex, text(size: 0.85em)[#it.supplement #it.level], it.body)
      } else {
        it.body
      }
    )
  }

  // Print document structure or nothing (user has to set it up manually)
  if not manual {
    thesis-titlepage()
    thesis-abstract()

    // Reset page numbering and start with document content
    thesis-start()

    body
  } else {
    body
  }
}
