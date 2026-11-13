/// A field job applications commonly ask for, offered as a starting point for a new snippet.
public struct SnippetSuggestion: Equatable, Identifiable, Sendable {
    public let tab: SnippetTab
    public let label: String
    /// An example of what to save, shown as the editor's placeholder.
    public let hint: String

    public var id: String { "\(tab.rawValue)/\(label)" }

    public init(tab: SnippetTab, label: String, hint: String) {
        self.tab = tab
        self.label = label
        self.hint = hint
    }
}

extension SnippetSuggestion {
    // Only free-text fields: dropdown-only questions (EEO, gender, veteran status) and
    // sensitive identifiers (SSN, date of birth) are deliberately left out.
    public static let all: [SnippetSuggestion] = [
        .init(tab: .me, label: "First name", hint: "Alex"),
        .init(tab: .me, label: "Last name", hint: "Morgan"),
        .init(tab: .me, label: "Full name", hint: "Alex Morgan"),
        .init(tab: .me, label: "Email", hint: "you@example.com"),
        .init(tab: .me, label: "Phone", hint: "+1 555 555 5555"),
        .init(tab: .me, label: "Street address", hint: "123 Main St, Apt 4"),
        .init(tab: .me, label: "City", hint: "New York"),
        .init(tab: .me, label: "State", hint: "NY"),
        .init(tab: .me, label: "ZIP code", hint: "10001"),
        .init(tab: .me, label: "Country", hint: "United States"),
        .init(tab: .me, label: "Current company", hint: "Acme Inc."),
        .init(tab: .me, label: "Current title", hint: "Senior Software Engineer"),
        .init(tab: .me, label: "Years of experience", hint: "8"),
        .init(tab: .me, label: "School", hint: "State University"),
        .init(tab: .me, label: "Degree", hint: "B.S. Computer Science"),
        .init(tab: .me, label: "Graduation year", hint: "2018"),
        .init(tab: .me, label: "Pronouns", hint: "they/them"),

        .init(tab: .links, label: "LinkedIn", hint: "https://www.linkedin.com/in/your-handle"),
        .init(tab: .links, label: "GitHub", hint: "https://github.com/your-handle"),
        .init(tab: .links, label: "Portfolio", hint: "https://your-portfolio.com"),
        .init(tab: .links, label: "Website", hint: "https://your-site.com"),
        .init(tab: .links, label: "Resume link", hint: "https://drive.google.com/…"),
        .init(tab: .links, label: "Stack Overflow", hint: "https://stackoverflow.com/users/…"),
        .init(tab: .links, label: "X / Twitter", hint: "https://x.com/your-handle"),

        .init(tab: .answers, label: "Work authorization", hint: "I am authorized to work in the United States."),
        .init(tab: .answers, label: "Visa sponsorship", hint: "I do not require sponsorship now or in the future."),
        .init(tab: .answers, label: "Salary expectation", hint: "$150,000–$170,000 base, flexible for the right role."),
        .init(tab: .answers, label: "Notice period", hint: "Two weeks"),
        .init(tab: .answers, label: "Start date", hint: "Available to start two weeks after an offer."),
        .init(tab: .answers, label: "Relocation", hint: "Open to relocating for the right role."),
        .init(tab: .answers, label: "Work preference", hint: "Remote or hybrid; open to on-site in NYC."),
        .init(tab: .answers, label: "How I heard", hint: "LinkedIn"),
        .init(tab: .answers, label: "About me", hint: "A two- or three-sentence summary of who you are."),
        .init(tab: .answers, label: "Why this role", hint: "What draws you to this kind of role."),
        .init(tab: .answers, label: "Why this company", hint: "A reusable opener you tweak per company."),
        .init(tab: .answers, label: "Why leaving", hint: "Why you're moving on from your current job."),
        .init(tab: .answers, label: "Cover note", hint: "A short cover letter you can paste and adjust."),
        .init(tab: .answers, label: "References", hint: "Available on request."),
    ]
}
