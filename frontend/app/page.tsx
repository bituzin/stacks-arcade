"use client";

import { useState } from "react";

const games = [
  {
    id: "coin-flip",
    name: "🪙 Coin Flip",
    description: "Heads or tails? Test your luck!",
    color: "from-yellow-500 to-orange-600",
    hoverColor: "hover:from-yellow-600 hover:to-orange-700"
  },
  {
    id: "emoji-battle",
    name: "⚔️ Emoji Battle",
    description: "Epic emoji combat arena",
    color: "from-red-500 to-pink-600",
    hoverColor: "hover:from-red-600 hover:to-pink-700"
  },
  {
    id: "guess-the-number",
    name: "🎲 Guess the Number",
    description: "Can you guess the right number?",
    color: "from-blue-500 to-cyan-600",
    hoverColor: "hover:from-blue-600 hover:to-cyan-700"
  },
  {
    id: "rock-paper-scissors",
    name: "✊ Rock Paper Scissors",
    description: "Classic game on blockchain",
    color: "from-green-500 to-emerald-600",
    hoverColor: "hover:from-green-600 hover:to-emerald-700"
  },
  {
    id: "higher-lower",
    name: "📊 Higher or Lower",
    description: "Predict the next number",
    color: "from-purple-500 to-violet-600",
    hoverColor: "hover:from-purple-600 hover:to-violet-700"
  },
  {
    id: "hot-potato",
    name: "🔥 Hot Potato",
    description: "Don't get caught holding it!",
    color: "from-orange-500 to-red-600",
    hoverColor: "hover:from-orange-600 hover:to-red-700"
  },
  {
    id: "tic-tac-toe",
    name: "⭕ Tic Tac Toe",
    description: "Classic strategy game",
    color: "from-indigo-500 to-blue-600",
    hoverColor: "hover:from-indigo-600 hover:to-blue-700"
  },
  {
    id: "lottery",
    name: "🎰 Lottery Demo",
    description: "Try your luck with lottery",
    color: "from-pink-500 to-rose-600",
    hoverColor: "hover:from-pink-600 hover:to-rose-700"
  }
];

export default function Home() {
  const [hoveredGame, setHoveredGame] = useState<string | null>(null);

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900">
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute w-96 h-96 bg-purple-500/20 rounded-full blur-3xl -top-48 -left-48 animate-pulse"></div>
        <div className="absolute w-96 h-96 bg-blue-500/20 rounded-full blur-3xl -bottom-48 -right-48 animate-pulse delay-1000"></div>
      </div>

      <div className="relative">
        <header className="pt-12 pb-8 px-4">
          <div className="max-w-6xl mx-auto text-center">
            <h1 className="text-6xl md:text-7xl font-bold mb-4 bg-gradient-to-r from-purple-400 via-pink-400 to-blue-400 bg-clip-text text-transparent animate-gradient">
              Stacks Arcade
            </h1>
            <p className="text-xl md:text-2xl text-gray-300 mb-2">
              Blockchain-Powered Mini Games
            </p>
            <p className="text-sm md:text-base text-gray-400 max-w-2xl mx-auto">
              Experience the future of gaming with Clarity smart contracts on Stacks blockchain.
              Choose your game and start playing!
            </p>
          </div>
        </header>

        <main className="px-4 pb-16">
          <div className="max-w-6xl mx-auto">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-12">
              {games.map((game) => (
                <button
                  key={game.id}
                  onMouseEnter={() => setHoveredGame(game.id)}
                  onMouseLeave={() => setHoveredGame(null)}
                  className={`group relative p-6 rounded-2xl bg-gradient-to-br ${game.color} ${game.hoverColor} 
                    transform transition-all duration-300 hover:scale-105 hover:shadow-2xl
                    ${hoveredGame === game.id ? 'ring-4 ring-white/50' : ''}`}
                >
                  <div className="text-left">
                    <h3 className="text-2xl font-bold text-white mb-2">
                      {game.name}
                    </h3>
                    <p className="text-white/90 text-sm">
                      {game.description}
                    </p>
                  </div>
                  
                  <div className={`absolute inset-0 flex items-center justify-center bg-black/40 rounded-2xl
                    transition-opacity duration-300 ${hoveredGame === game.id ? 'opacity-100' : 'opacity-0'}`}>
                    <span className="text-white font-bold text-lg">Play Now →</span>
                  </div>
                </button>
              ))}
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
              <div className="p-6 bg-white/10 backdrop-blur-sm rounded-xl border border-white/20">
                <div className="text-3xl mb-3">🔗</div>
                <h3 className="text-white font-bold text-lg mb-2">Blockchain Verified</h3>
                <p className="text-gray-300 text-sm">Every game runs on Clarity smart contracts with transparent results</p>
              </div>
              <div className="p-6 bg-white/10 backdrop-blur-sm rounded-xl border border-white/20">
                <div className="text-3xl mb-3">💎</div>
                <h3 className="text-white font-bold text-lg mb-2">Secure & Fair</h3>
                <p className="text-gray-300 text-sm">Provably fair gameplay powered by Stacks blockchain technology</p>
              </div>
              <div className="p-6 bg-white/10 backdrop-blur-sm rounded-xl border border-white/20">
                <div className="text-3xl mb-3">🎮</div>
                <h3 className="text-white font-bold text-lg mb-2">Play & Learn</h3>
                <p className="text-gray-300 text-sm">Educational playground for Stacks and Clarity development</p>
              </div>
            </div>

            <div className="flex flex-wrap justify-center gap-6 items-center">
              <a 
                href="https://github.com/bituzin/stacks-arcade" 
                target="_blank" 
                rel="noopener noreferrer"
                className="px-6 py-3 bg-white/10 hover:bg-white/20 backdrop-blur-sm rounded-lg border border-white/20 
                  text-white font-semibold transition-all duration-300 hover:scale-105"
              >
                📚 View on GitHub
              </a>
              <a 
                href="https://docs.stacks.co" 
                target="_blank" 
                rel="noopener noreferrer"
                className="px-6 py-3 bg-white/10 hover:bg-white/20 backdrop-blur-sm rounded-lg border border-white/20 
                  text-white font-semibold transition-all duration-300 hover:scale-105"
              >
                📖 Stacks Docs
              </a>
              <a 
                href="https://clarity-lang.org" 
                target="_blank" 
                rel="noopener noreferrer"
                className="px-6 py-3 bg-white/10 hover:bg-white/20 backdrop-blur-sm rounded-lg border border-white/20 
                  text-white font-semibold transition-all duration-300 hover:scale-105"
              >
                💡 Learn Clarity
              </a>
            </div>
          </div>
        </main>

        <footer className="text-center py-8 px-4 border-t border-white/10">
          <p className="text-gray-400 text-sm">
            Built with ❤️ using Next.js, Tailwind CSS, and Clarity Smart Contracts
          </p>
          <p className="text-gray-500 text-xs mt-2">
            Stacks Arcade © 2025 • Educational & Open Source
          </p>
        </footer>
      </div>
    </div>
  );
}
