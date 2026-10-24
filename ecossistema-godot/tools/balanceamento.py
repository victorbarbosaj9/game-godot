"""Réplica em Python da simulação do Godot, para testar balanceamento sem abrir a engine.
Uso: python tools/balanceamento.py
Altere os parâmetros em S (iguais aos .tres) e veja quais combinações vencem cada fase."""
import itertools
S = {
 'capim':    dict(P=1, pop=500, r=.5,  kb=1000, come=[],            tc=1,   ef=.5,  custo=1),
 'coelho':   dict(pop=100, r=.6,  come=['capim'],    tc=.8,  ef=.5,  custo=2),
 'raposa':   dict(pop=10,  r=.3,  come=['coelho'],   tc=2,   ef=.1,  custo=3),
 'gafanhoto':dict(pop=300, r=.8,  come=['capim'],    tc=.15, ef=.6,  custo=1),
 'sapo':     dict(pop=20,  r=.4,  come=['gafanhoto','caramujo'], tc=3, ef=.07, custo=2),
 'cobra':    dict(pop=6,   r=.25, come=['sapo','coelho'], tc=1.0, ef=.2,  custo=3),
 'caramujo': dict(pop=40,  r=.5,  come=['capim'],    tc=.5,  ef=2,   custo=0),
}
def sim(placed, fixed, N, ev=None):
    esp = list(placed)+list(fixed)
    pop = {e:S[e]['pop'] for e in esp}
    luz=1.0; agua=1.0; extinct=[]
    def K(e):
        s=S[e]
        if s.get('P'): return max(s['kb']*luz*agua,1)
        return max(sum(pop[p]*s['ef'] for p in s['come'] if p in pop),1)
    for t in range(1,N+1):
        if ev and t==ev[0]: luz*=ev[1]; agua*=ev[2]
        loss={e:0 for e in esp}
        for pr in esp:
            for pb in S[pr]['come']:
                if pb in pop: loss[pb]+=pop[pr]*S[pr]['tc']
        new={}
        for e in esp:
            p=pop[e];k=K(e)
            n=p+S[e]['r']*p*(1-p/k)-min(loss[e],p)
            new[e]=0 if n<1 else n
        for e in esp:
            if pop[e]>0 and new[e]==0: extinct.append((t,e))
        pop=new
    return extinct,pop
def explore(avail,fixed,req,budget,N,ev=None,verbose=True):
    wins=[];allc=[]
    for n in range(1,len(avail)+1):
        for c in itertools.combinations(avail,n):
            cost=sum(S[e]['custo'] for e in c)
            if cost>budget: continue
            if not all(r in c for r in req): continue
            ext,pop=sim(c,fixed,N,ev)
            bad=[x for x in ext if x[1] not in fixed]
            ok=not bad
            allc.append((c,cost,ok,bad[:1]))
            if ok: wins.append((c,cost))
    if verbose:
        for c,cost,ok,bad in allc: print(('WIN ' if ok else 'fail'),cost,c,bad)
    return wins,allc
if __name__=='__main__':
    print("fase 1 (20 turnos):"); explore(['capim','coelho','raposa'],[],['capim','coelho','raposa'],6,20)
    print("fase 2 (20 turnos):"); explore(['capim','coelho','gafanhoto','raposa','sapo'],[],['capim','coelho','raposa','sapo'],9,20)
    print("fase 3 (25 turnos, caramujo fixo):"); explore(['capim','coelho','gafanhoto','raposa','sapo'],['caramujo'],['capim','coelho'],6,25)
    print("fase 4 (30 turnos, evento no turno 10):"); explore(['capim','coelho','gafanhoto','raposa','sapo','cobra'],[],['capim','coelho','cobra'],7,30,(10,.5,.5))
