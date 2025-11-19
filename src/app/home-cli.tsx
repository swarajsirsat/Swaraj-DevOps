'use client';
import { Typewriter } from '@/components/typewriter';

const introLines = [
  { type: 'command' as const, text: 'cat intro.txt' },
  { type: 'response' as const, text: "Hi, I'm Swaraj S Sirsat — a passionate Cloud & DevOps Engineer with 4 years of hands-on experience in building, automating, and scaling cloud infrastructure." },
  { type: 'command' as const, text: './navigate.sh' },
  { type: 'response' as const, text: 'Use the navigation above to explore my skills, projects, and more.' }
];


export function HomeCli() {
  return (
    <Typewriter lines={introLines} />
  );
}
