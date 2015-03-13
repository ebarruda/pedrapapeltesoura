{
 Pedra, Papel e Tesoura
 Implementado no Lazarus por: Ericson Benjamim
 Contato: ericsonbenjamim@yahoo.com.br
 Licenca: GPL
}
unit PedraPapelTesoura_Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons;

type

  Objeto  = (Pedra, Papel, Tesoura);
  Jogador = (Computador, Humano);

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure Image4Click(Sender: TObject);
    procedure Image5Click(Sender: TObject);
  private
    { private declarations }
    procedure MessagemIntroducao;
    procedure ExibeMinhaJogada;
    procedure RecebeResposta;
    procedure ExibePontuacao;
    procedure MensagemVitoria;
    function JogadaAleatoria: Objeto;
    function EscolheJogada: Objeto;
    function Combina(X, Y, Comprimento: Integer): Boolean;
    procedure Procura(Comprimento: Integer);
    procedure AtualizaPontuacao;
    function PontuacaoNecessaria: Boolean;
    procedure RodaJogo;
    procedure ImagemEscolha(ObjetoEscolhido: Objeto);
  public
    { public declarations }
  end; 

const
  { maior valor da sequencia a procurar }
  ComprimentoMaximo = 5;

var
  Form1: TForm1; 
  { Registro de todas as rodadas }
  Historico: Array [Computador..Humano, 1..100] of Objeto;

  { Pontuacao dos Jogadores }
  Pontos: Array [Computador..Humano] of Integer;

  { Minha Jogada, sua reposta}
  Jogada, Resposta: Objeto;

  { Totais das jogadas usuais da sequencia mais recente }
  TotPedra, TotPapel, TotTesoura, TotEmpate: Integer;

  { Variaveis de controle }
  Comprimento, SemRodadas: Integer;
  Decidido, FimDeJogo: Boolean;
  NomeObjeto: Array[Pedra..Tesoura] of String;

implementation

{ TForm1 }

procedure TForm1.MessagemIntroducao;
{ Exibe a mensagem de introducao }
begin
  Memo1.Clear;
  Memo1.Lines.Add('Este programa roda o jogo Pedra, Papel e Tesoura. Cada um de nós deve pensar em um dos três objetos.');
  Memo1.Lines.Add('');
  Memo1.Lines.Add('A regra é que tesoura vence papel, papel vence pedra e pedra vence tesoura! Eu aposto que consigo');
  Memo1.Lines.Add('vencer voce no máximo em 50 rodadas.');
  Memo1.Lines.Add('');
  Memo1.Lines.Add('Eu já fiz minha escolha. Clique em uma das três imagens abaixo para fazer a sua.');
  Memo1.Lines.Add('Qual é sua jogada: Pedra, Papel ou Tesoura? ');
  Image1.Picture.Clear;
  Image2.Picture.Clear;
  Label2.Caption      := '0 ponto';
  Label4.Caption      := '0 ponto';
  Label6.Caption      := '0';
  TotEmpate           := 0;
  SemRodadas          := 0;
  Pontos[Computador]  := 0;
  Pontos[Humano]      := 0;
  FimDeJogo           := false;
end;

procedure TForm1.ExibeMinhaJogada;
{ Informa ao jogador sobre minha jogada }
begin
  Memo1.Lines.Add('Eu escolhi ' + NomeObjeto[Jogada] + '.');
  Memo1.Lines.Add('');
end;

procedure TForm1.RecebeResposta;
{ Recebe a resposta do jogador }
begin
  Memo1.Lines.Add('Qual eh sua jogada: Pedra, Papel ou Tesoura? ');
  Memo1.Lines.Add('');
end;

procedure TForm1.ExibePontuacao;
{ Exibe a pontuacao }
begin
  Label2.Caption := IntToStr(Pontos[Computador]) + ' ponto';
  if Pontos[Computador] > 1 then Label2.Caption := Label2.Caption + 's';
  Label4.Caption := IntToStr(Pontos[Humano]) + ' ponto';
  if Pontos[Humano] > 1 then Label4.Caption := Label4.Caption + 's';
  Label6.Caption := IntToStr(TotEmpate);
end;

procedure TForm1.MensagemVitoria;
{ Anuncia quem ganhou }
var
  StrJogador: String;
begin
  if Pontos[Computador] > Pontos[Humano] then
    StrJogador := 'eu, o Computador, ganhei!'
  else
    if Pontos[Computador] = Pontos[Humano] then
      StrJogador := 'houve um empate!'
    else
      StrJogador := 'você, Humano, ganhou!';
  Memo1.Lines.Add('Parece que ' + StrJogador);
  Memo1.Lines.Add('');
  Memo1.Lines.Add('Obrigado por jogar.');
  FimDeJogo := true;
end;

function TForm1.JogadaAleatoria: Objeto;
{
 Esta funcao eh chamada quando um numero
 particular de um padrao eh detectado.
 Um objeto aleatorio eh retornado.
}
begin
  {
   "RANDOM(253) + 3" deve retornar um
   inteiro aleatorio entre 3 e 255
  }
  case ((RANDOM(253) + 3) MOD 3) of
    0: JogadaAleatoria := Pedra;
    1: JogadaAleatoria := Papel;
    2: JogadaAleatoria := Tesoura;
  end;
end;

function TForm1.EscolheJogada: Objeto;
{
 Ve se alguma resposta tem a maioridade
 limpa e escolhe a correspondente jogada
}
begin
  Decidido := true;
  if (TotPapel > TotTesoura) and
     (TotPapel > TotPedra)
    then EscolheJogada := Tesoura
  else
    if (TotTesoura > TotPapel) and
       (TotTesoura > TotPedra)
      then EscolheJogada := Pedra
    else
      if (TotPedra > TotPapel) and
         (TotPedra > TotTesoura)
       then EscolheJogada := Papel
      else
        begin
          EscolheJogada := JogadaAleatoria;
          Decidido      := false;
        end;
  case EscolheJogada of
    Pedra:   Image1.Picture.LoadFromFile('pedra.xpm');
    Papel:   Image1.Picture.LoadFromFile('papel.xpm');
    Tesoura: Image1.Picture.LoadFromFile('tesoura.xpm');
  end;
end;

function TForm1.Combina(X, Y, Comprimento: Integer): Boolean;
{
 Compara as sequencias historicas em
 X e Y sobre o comprimento informado
}
var
  I: Integer;
begin
  I := 0;
  while
    (I < Comprimento) and
    (Historico[Computador, X + 1] = Historico[Computador, Y + 1]) and
    (Historico[Humano, X + 1]     = Historico[Humano, Y + 1])
  do
    I := I + 1;
  Combina := (I = Comprimento);
end;

procedure TForm1.Procura(Comprimento: Integer);
{
 Procura pela sua proxima jogada apos cada
 combinacao bem sucedida de comprimento espeficado
}
var
  B, T: Integer;
begin
  TotPedra   := 0;
  TotPapel   := 0;
  TotTesoura := 0;
  { Ultima Sequencia }
  T := SemRodadas - Comprimento;
  { Para cada sequencia mais proxima do inicio faca }
  for B := 1 to T - 1 do
    if Combina(B, T, Comprimento) then
      { Grava a proxima resposta executada }
      case Historico[Humano, B + Comprimento] of
        Pedra  : TotPedra   := TotPedra   + 1;
        Papel  : TotPapel   := TotPapel   + 1;
        Tesoura: TotTesoura := TotTesoura + 1;
      end;
end;

procedure TForm1.AtualizaPontuacao;
{ Decide quem ganhou nesta rodada }
var PontosAnteriores: Array [Computador..Humano] of Integer;
begin
  PontosAnteriores[Humano]     := Pontos[Humano];
  PontosAnteriores[Computador] := Pontos[Computador];
  case Jogada of
    Pedra:
      case Resposta of
        Pedra  : TotEmpate := TotEmpate + 1;
        Papel  : Pontos[Humano]     := Pontos[Humano] + 1;
        Tesoura: Pontos[Computador] := Pontos[Computador] + 1;
      end;
    Papel:
      case Resposta of
        Pedra  : Pontos[Computador] := Pontos[Computador] + 1;
        Papel  : TotEmpate := TotEmpate + 1;
        Tesoura: Pontos[Humano]     := Pontos[Humano] + 1;
      end;
    Tesoura:
      case Resposta of
        Pedra  : Pontos[Humano]     := Pontos[Humano] + 1;
        Papel  : Pontos[Computador] := Pontos[Computador] + 1;
        Tesoura: TotEmpate := TotEmpate + 1;
      end;
  end;
  if Pontos[Humano] > PontosAnteriores[Humano] then
    Memo1.Lines.Add(NomeObjeto[Resposta] + ' vence ' + NomeObjeto[Jogada] + '.')
  else
    if Pontos[Computador] > PontosAnteriores[Computador] then
      Memo1.Lines.Add(NomeObjeto[Jogada] + ' vence ' + NomeObjeto[Resposta] + '.')
    else
      Memo1.Lines.Add('Houve um empate nesta rodada.');
  Memo1.Lines.Add('');
end;

function TForm1.PontuacaoNecessaria: Boolean;
{ Avalia condicoes para terminar o jogo }
begin
  PontuacaoNecessaria := ((Pontos[Computador] >= 50) or
                          (Pontos[Humano] >= 50)) and
                         (ABS(Pontos[Computador] - Pontos[Humano]) > 1);
end;

procedure TForm1.RodaJogo;
{ Rotina principal }
begin
  SemRodadas  := SemRodadas + 1;
  Comprimento := ComprimentoMaximo;
  Decidido    := false;
  repeat
    Procura(Comprimento);
    Jogada      := EscolheJogada;
    Comprimento := Comprimento - 1;
  until (Decidido) or (Comprimento = 0);
  ExibeMinhaJogada;
  Historico[Computador, SemRodadas] := Jogada;
  Historico[Humano, SemRodadas]     := Resposta;
  AtualizaPontuacao;
  ExibePontuacao;
end;

procedure TForm1.ImagemEscolha(ObjetoEscolhido: Objeto);
begin
  if not FimDeJogo then
    begin
      Image2.Picture.LoadFromFile(LowerCase(NomeObjeto[ObjetoEscolhido]) + '.xpm');
      Memo1.Clear;
      Memo1.Lines.Add('Você escolheu ' + NomeObjeto[ObjetoEscolhido] + '.');
      Memo1.Lines.Add('');
      Resposta := ObjetoEscolhido;
      RodaJogo;
    end
  else
    begin
      Image1.Picture.Clear;
      Image2.Picture.Clear;
      Memo1.Clear;
      Memo1.Lines.Add('O jogo chegou ao fim. Clique em Início para jogar novamente.');
      Memo1.Lines.Add('');
    end;
  if PontuacaoNecessaria then MensagemVitoria
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  { Configura e formata os componentes do form }
  Form1.Caption   := 'Pedra, Papel e Tesoura @ Lazarus';
  Form1.Height    := 358;
  Form1.Width     := 592;
  { Centraliza form }
  Form1.Left      := (Screen.Width  div 2) - (Form1.Width div 2);
  Form1.Top       := (Screen.Height div 2) - (Form1.Height div 2);
  Button1.Caption := 'Início';
  Button1.Left    := 212;
  Button1.Top     := 317;
  Button2.Caption := 'Sair';
  Button2.Left    := 305;
  Button2.Top     := 317;
  Memo1.Font.Name := 'Courier New';
  Memo1.Font.Size := 10;
  Memo1.ReadOnly  := true;
  Memo1.Left      := 199;
  Memo1.Top       := 16;
  Memo1.Height    := 208;
  Memo1.Width     := 377;
  Label1.Caption  := 'Computador:';
  Label1.Left     := 16;
  Label1.Top      := 46;
  Label2.Left     := 23;
  Label2.Top      := 62;
  Label3.Caption  := 'Humano:';
  Label3.Left     := 24;
  Label3.Top      := 136;
  Label4.Left     := 23;
  Label4.Top      := 152;
  Label5.Caption  := 'Empate(s):';
  Label5.Left     := 26;
  Label5.Top      := 200;
  Label6.Left     := 112;
  Label6.Top      := 200;
  Image1.AutoSize := true;
  Image1.Left     := 100;
  Image1.Top      := 32;
  Image2.AutoSize := true;
  Image2.Left     := 100;
  Image2.Top      := 120;
  Image3.Left     := 141;
  Image3.Top      := 240;
  Image4.Left     := 253;
  Image4.Top      := 240;
  Image5.Left     := 365;
  Image5.Top      := 240;
  Image3.AutoSize := true;
  Image4.AutoSize := true;
  Image5.AutoSize := true;
  { Carrega bitmaps }
  if not FileExists('pedra.xpm') or
     not FileExists('papel.xpm') or
     not FileExists('tesoura.xpm') then begin
    ShowMessage('Arquivo(s) de imagem XPM não encontrado(s)!');
    Halt;
  end;
  Image3.Picture.LoadFromFile('pedra.xpm');
  Image4.Picture.LoadFromFile('papel.xpm');
  Image5.Picture.LoadFromFile('tesoura.xpm');
  NomeObjeto[Pedra]   := 'Pedra';
  NomeObjeto[Papel]   := 'Papel';
  NomeObjeto[Tesoura] := 'Tesoura';
  MessagemIntroducao;
end;

procedure TForm1.Image3Click(Sender: TObject);
begin
  ImagemEscolha(Pedra);
end;

procedure TForm1.Image4Click(Sender: TObject);
begin
  ImagemEscolha(Papel);
end;

procedure TForm1.Image5Click(Sender: TObject);
begin
  ImagemEscolha(Tesoura);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  MessagemIntroducao;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Form1.Close;
end;

initialization
  {$I PedraPapelTesoura_Unit1.lrs}

end.

