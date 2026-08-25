 "use client";
import {useState} from "react";
import {createClient} from "../../lib/supabase-browser";
import {useRouter} from "next/navigation";
export default function Login(){
  const [email,setEmail]=useState(""); const [password,setPassword]=useState("");
  const [msg,setMsg]=useState(""); const router=useRouter();
  async function submit(e){
    e.preventDefault(); setMsg("Signing in…");
    const supabase=createClient();
    const {error}=await supabase.auth.signInWithPassword({email,password});
    if(error){setMsg(error.message);return}
    router.push("/dashboard");
  }
  return <main className="center"><form className="panel" onSubmit={submit}>
    <div className="eyebrow">UMAT-101</div><h1>Sign in</h1>
    <label>Email<input type="email" value={email} onChange={e=>setEmail(e.target.value)} required /></label>
    <label>Password<input type="password" value={password} onChange={e=>setPassword(e.target.value)} required /></label>
    <button className="button">Sign in</button><p className="muted">{msg}</p>
  </form></main>
}