"""Gera os sprites 32x32 e os fundos 480x270 (pixel art placeholder) em assets/.
Uso: pip install pillow && python tools/gerar_arte.py
Edite as funções de cada espécie/fundo para mudar o visual, ou substitua os PNGs por arte própria."""
import math, random, os
from PIL import Image, ImageDraw
OUT=os.path.join(os.path.dirname(os.path.abspath(__file__)),'..','assets')
os.makedirs(OUT+'/sprites',exist_ok=True); os.makedirs(OUT+'/backgrounds',exist_ok=True)
DARK=(28,30,42,255)
def C(r,g,b,a=255): return (r,g,b,a)

def outline(img):
    w,h=img.size; px=img.load(); out=img.copy(); op=out.load()
    for y in range(h):
        for x in range(w):
            if px[x,y][3]==0:
                for dx,dy in ((1,0),(-1,0),(0,1),(0,-1)):
                    nx,ny=x+dx,y+dy
                    if 0<=nx<w and 0<=ny<h and px[nx,ny][3]>0:
                        op[x,y]=DARK; break
    return out

def new(): 
    im=Image.new('RGBA',(32,32),(0,0,0,0)); return im, ImageDraw.Draw(im)

def capim():
    im,d=new()
    d.rectangle((3,26,28,29),fill=C(120,82,48)); d.rectangle((3,26,28,26),fill=C(160,112,66))
    blades=[(7,12,-1,C(60,140,55)),(11,19,1,C(95,190,70)),(15,24,0,C(150,225,100)),(19,17,-1,C(95,190,70)),(23,13,1,C(60,140,55)),(26,9,0,C(95,190,70))]
    for x,h,lean,col in blades:
        d.polygon([(x-2,26),(x+2,26),(x+lean,26-h)],fill=col)
    d.line([(15,25),(15,9)],fill=C(190,240,130))
    return outline(im)

def coelho():
    im,d=new()
    d.ellipse((6,15,24,28),fill=C(205,165,115))
    d.ellipse((9,21,19,28),fill=C(228,196,150))
    d.ellipse((3,19,8,24),fill=C(246,242,232))
    d.ellipse((17,9,29,21),fill=C(205,165,115))
    d.ellipse((19,0,22,11),fill=C(205,165,115)); d.ellipse((23,1,26,11),fill=C(205,165,115))
    d.line([(20,2),(20,9)],fill=C(231,150,160)); d.line([(24,3),(24,9)],fill=C(231,150,160))
    d.ellipse((10,25,18,29),fill=C(176,132,86))
    d.point((25,14),fill=DARK); d.point((26,14),fill=DARK)
    d.point((29,16),fill=C(231,120,140))
    return outline(im)

def raposa():
    im,d=new()
    d.ellipse((1,10,10,27),fill=C(240,130,50)); d.ellipse((1,10,5,15),fill=C(246,242,232))
    d.ellipse((6,14,24,27),fill=C(240,130,50))
    d.ellipse((12,19,20,27),fill=C(246,236,220))
    d.rectangle((9,25,12,30),fill=C(90,50,38)); d.rectangle((19,25,22,30),fill=C(90,50,38))
    d.ellipse((17,8,29,19),fill=C(240,130,50))
    d.polygon([(25,14),(31,17),(25,19)],fill=C(246,236,220))
    d.polygon([(18,10),(19,1),(24,8)],fill=C(240,130,50)); d.polygon([(23,8),(27,0),(29,10)],fill=C(240,130,50))
    d.polygon([(19,8),(19,4),(22,7)],fill=C(90,50,38)); d.polygon([(25,7),(27,3),(27,8)],fill=C(90,50,38))
    d.point((24,13),fill=DARK); d.point((25,13),fill=DARK); d.point((31,17),fill=DARK)
    return outline(im)

def gafanhoto():
    im,d=new()
    d.ellipse((5,13,26,22),fill=C(150,205,60))
    d.ellipse((8,11,21,17),fill=C(205,235,120))
    d.ellipse((22,10,30,20),fill=C(150,205,60))
    d.polygon([(10,17),(4,27),(8,28),(14,20)],fill=C(105,165,45))
    d.polygon([(14,20),(18,22),(19,28),(15,28)],fill=C(105,165,45))
    d.line([(26,10),(29,3)],fill=DARK); d.line([(28,11),(31,5)],fill=DARK)
    d.point((26,13),fill=DARK); d.point((27,13),fill=DARK); d.point((26,12),fill=C(255,255,255))
    return outline(im)

def sapo():
    im,d=new()
    d.ellipse((4,12,28,29),fill=C(55,170,150))
    d.ellipse((10,20,22,29),fill=C(190,232,196))
    d.ellipse((7,6,15,14),fill=C(55,170,150)); d.ellipse((17,6,25,14),fill=C(55,170,150))
    d.ellipse((9,8,13,12),fill=C(255,255,255)); d.ellipse((19,8,23,12),fill=C(255,255,255))
    d.point((11,10),fill=DARK); d.point((12,10),fill=DARK); d.point((21,10),fill=DARK); d.point((22,10),fill=DARK)
    d.line([(8,20),(24,20)],fill=DARK)
    d.ellipse((2,24,9,30),fill=C(40,135,120)); d.ellipse((23,24,30,30),fill=C(40,135,120))
    for p in ((9,15),(22,16),(15,14),(12,17)): d.point(p,fill=C(35,120,105))
    return outline(im)

def cobra():
    im,d=new()
    pts=[(6,27),(11,23),(16,26),(21,22),(23,17),(23,12)]
    for i in range(len(pts)-1):
        (x0,y0),(x1,y1)=pts[i],pts[i+1]
        for t in range(0,11):
            x=x0+(x1-x0)*t/10; y=y0+(y1-y0)*t/10
            d.ellipse((x-3,y-3,x+3,y+3),fill=C(150,105,205))
    for (x,y) in pts[1:-1]:
        d.ellipse((x-1,y-1,x+1,y+1),fill=C(200,170,240))
    d.ellipse((19,3,29,13),fill=C(150,105,205))
    d.point((23,7),fill=C(255,255,255)); d.point((24,7),fill=DARK); d.point((27,7),fill=C(255,255,255)); d.point((28,7),fill=DARK)
    d.line([(24,13),(24,16)],fill=C(225,60,60)); d.point((23,16),fill=C(225,60,60)); d.point((25,16),fill=C(225,60,60))
    return outline(im)

def caramujo():
    im,d=new()
    d.ellipse((2,19,29,28),fill=C(205,190,150))
    d.ellipse((22,15,30,24),fill=C(205,190,150))
    d.line([(26,16),(28,9)],fill=C(205,190,150)); d.line([(23,16),(23,10)],fill=C(205,190,150))
    d.point((28,8),fill=DARK); d.point((23,9),fill=DARK)
    d.ellipse((6,5,24,25),fill=C(196,86,62))
    d.ellipse((9,8,21,22),outline=C(150,55,45),fill=C(196,86,62))
    d.ellipse((12,11,18,19),outline=C(150,55,45),fill=C(224,126,92))
    d.point((15,14),fill=C(150,55,45))
    return outline(im)

for nome,fn in dict(capim=capim,coelho=coelho,raposa=raposa,gafanhoto=gafanhoto,sapo=sapo,cobra=cobra,caramujo=caramujo).items():
    fn().save(f'{OUT}/sprites/{nome}.png')

# ---------------- fundos 480x270 ----------------
W,H=480,270
def lerp(a,b,t): return tuple(int(a[i]+(b[i]-a[i])*t) for i in range(3))
def sky(d,top,bot,bands=9,limit=170):
    for i in range(bands):
        y0=int(limit*i/bands); y1=int(limit*(i+1)/bands)
        d.rectangle((0,y0,W,y1),fill=lerp(top,bot,i/(bands-1)))
def hills(d,base,amp,col,seed,step=4,freq=0.018):
    rnd=random.Random(seed); ph=rnd.random()*6
    for x in range(0,W,step):
        y=base+int(amp*math.sin(x*freq+ph)+amp*0.5*math.sin(x*freq*2.3+ph*2))
        d.rectangle((x,y,x+step,H),fill=col)
def clouds(d,seed,n,col=(250,250,245)):
    rnd=random.Random(seed)
    for _ in range(n):
        x=rnd.randint(0,W-60); y=rnd.randint(12,70)
        for dx,dy,w,h in ((0,6,56,10),(10,0,34,10),(22,-4,22,10)): d.rectangle((x+dx,y+dy,x+dx+w,y+dy+h),fill=col)
def sun(d,x,y,r,col): d.ellipse((x-r,y-r,x+r,y+r),fill=col)
def tufts(d,y0,col,seed,n=140):
    rnd=random.Random(seed)
    for _ in range(n):
        x=rnd.randint(0,W-4); y=rnd.randint(y0,H-4)
        d.rectangle((x,y-3,x+1,y),fill=col); d.rectangle((x+3,y-2,x+4,y),fill=col)
def tree(d,x,y,h,trunk,leaf,leaf2):
    d.rectangle((x-3,y-h,x+3,y),fill=trunk)
    for k,(dx,dy,w,hh) in enumerate(((-18,-h-6,36,14),(-14,-h-18,28,14),(-9,-h-28,18,12))):
        d.rectangle((x+dx,y+dy,x+dx+w,y+dy+hh),fill=leaf if k%2==0 else leaf2)

def save(im,name): im.save(f'{OUT}/backgrounds/{name}.png')

# fase 1: campo aberto
im=Image.new('RGB',(W,H)); d=ImageDraw.Draw(im)
sky(d,(112,190,235),(205,236,248),limit=190); sun(d,380,48,18,(255,240,170)); clouds(d,1,4)
hills(d,150,10,(110,170,95),2); hills(d,178,9,(88,150,78),3); hills(d,208,7,(70,130,62),4)
tufts(d,214,(150,210,110),5); save(im,'fase1')

# fase 2: mata (floresta)
im=Image.new('RGB',(W,H)); d=ImageDraw.Draw(im)
sky(d,(90,150,120),(170,210,150),limit=190)
for x in range(30,W,70):
    d.polygon([(x,0),(x+26,0),(x+90,190),(x+60,190)],fill=(190,225,160))
hills(d,140,8,(52,110,70),6)
rnd=random.Random(7)
for x in range(10,W,34): tree(d,x+rnd.randint(-6,6),175,rnd.randint(34,52),(86,60,40),(40,100,58),(54,125,70))
hills(d,200,6,(38,88,52),8); tufts(d,208,(110,180,90),9); save(im,'fase2')

# fase 3: várzea ao entardecer, invasora
im=Image.new('RGB',(W,H)); d=ImageDraw.Draw(im)
sky(d,(235,150,110),(252,214,150),limit=170); sun(d,240,150,26,(255,236,170)); clouds(d,11,3,(255,226,196))
hills(d,150,8,(120,110,110),12)
d.rectangle((0,176,W,H),fill=(78,140,150))
for y in range(184,H,10): d.rectangle((0,y,W,y+2),fill=(110,170,175))
hills(d,200,5,(86,128,70),13)
rnd=random.Random(14)
for _ in range(60):
    x=rnd.randint(0,W); y=rnd.randint(205,H-6)
    d.rectangle((x,y-16,x+1,y),fill=(60,100,55)); d.rectangle((x+2,y-10,x+3,y),fill=(80,125,60))
save(im,'fase3')

# fase 4: desmatamento
im=Image.new('RGB',(W,H)); d=ImageDraw.Draw(im)
sky(d,(196,150,110),(238,200,150),limit=190); sun(d,100,60,22,(250,214,140))
for y in range(30,120,24): d.rectangle((0,y,W,y+6),fill=(206,170,130))
hills(d,160,9,(150,112,84),15); hills(d,190,8,(124,90,68),16); hills(d,220,6,(104,74,56),17)
rnd=random.Random(18)
for x in range(20,W,52):
    y=rnd.randint(224,262); d.rectangle((x,y-10,x+14,y),fill=(88,60,42)); d.rectangle((x,y-10,x+14,y-8),fill=(150,110,76))
tree(d,420,200,40,(70,48,34),(70,110,60),(86,130,70)); tree(d,455,210,30,(70,48,34),(70,110,60),(86,130,70))
save(im,'fase4')

# menu: campo ao entardecer
im=Image.new('RGB',(W,H)); d=ImageDraw.Draw(im)
sky(d,(70,100,170),(250,190,130),limit=190); sun(d,330,150,22,(255,226,150)); clouds(d,21,3,(240,200,190))
hills(d,150,10,(70,110,96),22); hills(d,178,9,(54,92,80),23); hills(d,208,7,(40,76,64),24)
tufts(d,214,(96,150,100),25); save(im,'menu')

# folha de contato para conferência
sheet=Image.new('RGBA',(7*(96+8)+8,96+16),(60,70,70,255))
for i,n in enumerate(['capim','coelho','raposa','gafanhoto','sapo','cobra','caramujo']):
    s=Image.open(f'{OUT}/sprites/{n}.png').resize((96,96),Image.NEAREST)
    sheet.paste(s,(8+i*104,8),s)
sheet.save('sprites_conferencia.png')
bg=Image.new('RGB',(W*2,H*3//1))
names=['fase1','fase2','fase3','fase4','menu']
cont=Image.new('RGB',(W*3,H*2),(0,0,0))
for i,n in enumerate(names):
    cont.paste(Image.open(f'{OUT}/backgrounds/{n}.png'),((i%3)*W,(i//3)*H))
cont.save('fundos_conferencia.png')
print('ok')
