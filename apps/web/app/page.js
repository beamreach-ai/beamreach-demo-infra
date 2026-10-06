export const dynamic = "force-dynamic";

export default function Home() {
  return (
    <main style={{ padding: "4rem", maxWidth: 720, margin: "0 auto" }}>
      <h1>Storefront</h1>
      <p>Catalogue, checkout and order history.</p>
      <p style={{ color: "#666" }}>Build {process.env.BUILD_ID || "local"} · region {process.env.AWS_REGION || "unknown"}</p>
    </main>
  );
}
