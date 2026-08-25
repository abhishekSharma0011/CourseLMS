import Link from "next/link";
export default function Home() {
  return <main className="center"><div className="hero">
    <div className="eyebrow">UMAT-101</div>
    <h1>Differential Calculus</h1>
    <p>Course LMS for S. Balasubramanian, Abhishek Sharma and CH Ramanjaneyulu.</p>
    <Link className="button" href="/login">Enter LMS →</Link>
  </div></main>;
}