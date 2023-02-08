import { adjectives, nouns } from "@/constants/wordlist";

export const getRandomSymbolAndName = () => {
  const adjective = adjectives[Math.floor(Math.random() * adjectives.length)];
  const noun = nouns[Math.floor(Math.random() * nouns.length)];

  return {
    name: `${adjective.charAt(0).toUpperCase() + adjective.slice(1)} ${
      noun.charAt(0).toUpperCase() + noun.slice(1)
    } Token`,
    symbol: `${adjective.substring(0, 3).toUpperCase()}${noun
      .substring(0, 3)
      .toUpperCase()}-${Math.floor(Math.random() * 100) + 1}`,
  };
};
