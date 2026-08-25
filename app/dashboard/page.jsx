import {createClient} from "../../lib/supabase-server";
import {redirect} from "next/navigation";
export default async function Dashboard(){
  const supabase=await createClient();
  const {data:{user}}=await supabase.auth.getUser();
  if(!user) redirect("/login");
  const {data:profile}=await supabase.from("profiles").select("full_name,role").eq("id",user.id).single();
  const {data:course}=await supabase.from("courses").select("*").eq("code","UMAT-101").single();
  const {data:modules}=await supabase.from("modules").select("*").eq("course_id",course?.id).order("position");
  return <main className="shell"><header><div><div className="eyebrow">UMAT-101</div><h1>Differential Calculus</h1></div><div>{profile?.full_name || user.email}<br/><span className="muted">{profile?.role || "student"}</span></div></header>
    <section className="panel"><h2>Modules</h2>{(modules||[]).map(m=><article className="module" key={m.id}><strong>Module {m.position} — {m.title}</strong><p>{m.description}</p><span className="muted">{m.textbook_reference||""}</span></article>)}</section>
  </main>
}