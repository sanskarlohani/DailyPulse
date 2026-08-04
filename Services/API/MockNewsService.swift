import Foundation

final class MockNewsService: NewsServiceProtocol {
    static let shared = MockNewsService()
    
    init() {}
    
    func fetchTopHeadlines(category: String?, page: Int) async throws -> [Article] {
        try await Task.sleep(nanoseconds: 1_000_000_000) // Simulate network delay
        
        let selectedCategory = category ?? "General"
        return mockArticles.filter { 
            $0.category?.lowercased() == selectedCategory.lowercased() || selectedCategory.lowercased() == "general"
        }
    }
    
    func searchArticles(query: String, page: Int) async throws -> [Article] {
        try await Task.sleep(nanoseconds: 500_000_000)
        if query.isEmpty { return [] }
        return mockArticles.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            ($0.articleDescription?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }
    
    func fetchBreakingNews() async throws -> [Article] {
        try await Task.sleep(nanoseconds: 800_000_000)
        return Array(mockArticles.prefix(3))
    }
    
    // MARK: - Mock Data Set
    let mockArticles: [Article] = [
        Article(
            url: "https://example.com/tech-news-1",
            title: "Apple Announces Groundbreaking Spatial Computing Features for visionOS",
            articleDescription: "Apple unveiled next-generation spatial computing extensions that blur the lines between physical and virtual worlds. The update brings advanced gesture recognition, high-fidelity windows, and spatial sharing frameworks to developers.",
            urlToImage: "https://picsum.photos/id/1/800/600",
            publishedAt: "2026-08-04T10:15:30Z",
            content: "Apple has announced major updates to its spatial computing platform, visionOS. The updates focus on enhancing productivity, collaborative work, and immersive entertainment. Developers will now have access to advanced tracking and environment mapping APIs, enabling objects in spatial environments to respond dynamically to lighting conditions and hand motions. \"Spatial computing is no longer a futuristic concept; it is the modern interface for work and play,\" said Apple's VP of software design. The update will roll out to all headsets later this fall, with developer betas available starting today. Initial feedback suggests significant performance improvements and reduced latency in hand-tracking operations.",
            author: "Sarah Jenkins",
            sourceName: "TechPulse",
            category: "Technology"
        ),
        Article(
            url: "https://example.com/business-news-1",
            title: "Global Markets Rally Amid Interest Rate Cuts and Inflation Easing",
            articleDescription: "Stocks indices climbed to historic highs as central banks indicated an easing of monetary policy, providing relief to global supply lines and enterprise operations.",
            urlToImage: "https://picsum.photos/id/10/800/600",
            publishedAt: "2026-08-04T08:30:00Z",
            content: "Stock markets worldwide rallied today after the Federal Reserve and major central banks announced a coordinated series of interest rate cuts. Analysts believe this signals the end of the high-inflation era that has constrained consumer spending and business investment for several quarters. The Dow Jones Industrial Average rose by 1.5%, while European and Asian indexes posted similar gains. Retail and tech stocks led the surge, with investors showing renewed confidence in growth assets. Central banks hinted that further cuts might follow if inflation remains within target ranges.",
            author: "David Vance",
            sourceName: "Financial Times",
            category: "Business"
        ),
        Article(
            url: "https://example.com/sports-news-1",
            title: "Championship Underdog Secures Dramatic Victory in Final Seconds",
            articleDescription: "A thrilling grand finale concluded with an unexpected buzzer-beater shot, securing the trophy for the tournament underdogs after a stunning comeback.",
            urlToImage: "https://picsum.photos/id/26/800/600",
            publishedAt: "2026-08-03T18:45:00Z",
            content: "In one of the most memorable finals in recent history, the tournament underdogs pulled off an incredible victory against the reigning champions. Trailing by 12 points entering the final quarter, the team put on a defensive masterclass combined with surgical three-point shooting. With only 1.2 seconds remaining on the clock, guard Marcus Reed shot a spectacular buzzer-beater to win the game by a single point. Fans erupted into celebration as coaches and bench players flooded the court. 'We believed when nobody else did,' said the emotional head coach in his post-game interview.",
            author: "Robert Miller",
            sourceName: "SportsWorld",
            category: "Sports"
        ),
        Article(
            url: "https://example.com/science-news-1",
            title: "James Webb Telescope Discovers Atmospheres on Habitable-Zone Exoplanets",
            articleDescription: "Astronomers have detected atmospheric signatures containing water vapor and carbon dioxide on exoplanets orbiting a nearby red dwarf star.",
            urlToImage: "https://picsum.photos/id/48/800/600",
            publishedAt: "2026-08-03T14:20:00Z",
            content: "Using the high-precision spectrometers aboard the James Webb Space Telescope, an international team of scientists has identified atmospheric indicators on two rocky planets orbiting within the habitable zone of a red dwarf star 40 light-years away. This is the first time water vapor and carbon molecules have been detected on rocky worlds orbiting a foreign solar system, representing a major milestone in the search for extraterrestrial life. 'The atmosphere of these worlds shows they could theoretically sustain liquid water,' said the principal investigator. Next-phase studies will focus on analyzing potential biosignature gases.",
            author: "Dr. Elena Rostova",
            sourceName: "Cosmos Journal",
            category: "Science"
        ),
        Article(
            url: "https://example.com/health-news-1",
            title: "New Immunotherapy Shows 90% Success Rate in Clinical Trials",
            articleDescription: "Medical researchers have published a landmark study detailing a new oncology treatment that activates target T-cells with minimal side effects.",
            urlToImage: "https://picsum.photos/id/82/800/600",
            publishedAt: "2026-08-02T09:00:00Z",
            content: "A revolutionary cancer treatment has shown unprecedented results in Phase II clinical trials. The therapy, which leverages engineered T-cells to specifically target protein receptors on tumor surfaces, achieved complete remission in 90% of participating patients. Unlike traditional chemotherapy, this target mechanism spares healthy cells, drastically reducing secondary side effects like nausea and hair loss. Researchers are optimistic that FDA approval could be expedited, potentially bringing this life-saving treatment to hospitals within the next 18 months.",
            author: "Aria Albright",
            sourceName: "Medical Insider",
            category: "Health"
        ),
        Article(
            url: "https://example.com/politics-news-1",
            title: "International Coalition Signs Historic Climate Pact in Paris Accord",
            articleDescription: "Leaders from over fifty nations have ratified an aggressive emissions agreement targetting a net-zero transition by the year 2040.",
            urlToImage: "https://picsum.photos/id/60/800/600",
            publishedAt: "2026-08-02T11:10:00Z",
            content: "At the conclusion of the international summit in Paris, representatives from 54 nations signed a legally binding treaty to accelerate carbon reduction schedules. The treaty mandates that signatory countries phase out coal-fired power plants, expand green infrastructure subsidies, and establish strict carbon taxes. Crucially, the agreement includes a financial support framework funded by developed nations to assist emerging economies in their transition. 'This is the most aggressive commitment to global sustainability ever ratified,' declared the summit chairperson.",
            author: "Arthur Pendelton",
            sourceName: "Global Review",
            category: "Politics"
        ),
        Article(
            url: "https://example.com/entertainment-news-1",
            title: "Indie Sci-Fi Film Sweeps Awards Season with Dynamic Screenplay",
            articleDescription: "A low-budget independent feature surprised critics and audiences by dominating the annual awards, taking home Best Picture and Screenplay.",
            urlToImage: "https://picsum.photos/id/96/800/600",
            publishedAt: "2026-08-01T20:30:00Z",
            content: "In a stunning upset, the indie sci-fi drama 'Echoes of Tomorrow' walked away with five major awards, including Best Picture, at the annual cinema gala last night. Produced on a modest budget of $5 million, the film competed against blockbuster releases backed by major studios. Critics have praised the film's innovative narrative structure and powerful character development. 'This shows that a compelling story and visual sincerity still matter more than massive production budgets,' the director stated during her acceptance speech.",
            author: "Chloe Bennett",
            sourceName: "Hollywood Chronicles",
            category: "Entertainment"
        )
    ]
}
