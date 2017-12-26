{******************************************************************************}
{ Projeto: Componente ACBrNFe                                                  }
{  Biblioteca multiplataforma de componentes Delphi para emiss�o de Nota Fiscal}
{ eletr�nica - NFe - http://www.nfe.fazenda.gov.br                             }

{ Direitos Autorais Reservados (c) 2015 Daniel Simoes de Almeida               }
{                                       Andr� Ferreira de Moraes               }

{ Colaboradores nesse arquivo:                                                 }

{  Voc� pode obter a �ltima vers�o desse arquivo na pagina do Projeto ACBr     }
{ Componentes localizado em http://www.sourceforge.net/projects/acbr           }


{  Esta biblioteca � software livre; voc� pode redistribu�-la e/ou modific�-la }
{ sob os termos da Licen�a P�blica Geral Menor do GNU conforme publicada pela  }
{ Free Software Foundation; tanto a vers�o 2.1 da Licen�a, ou (a seu crit�rio) }
{ qualquer vers�o posterior.                                                   }

{  Esta biblioteca � distribu�da na expectativa de que seja �til, por�m, SEM   }
{ NENHUMA GARANTIA; nem mesmo a garantia impl�cita de COMERCIABILIDADE OU      }
{ ADEQUA��O A UMA FINALIDADE ESPEC�FICA. Consulte a Licen�a P�blica Geral Menor}
{ do GNU para mais detalhes. (Arquivo LICEN�A.TXT ou LICENSE.TXT)              }

{  Voc� deve ter recebido uma c�pia da Licen�a P�blica Geral Menor do GNU junto}
{ com esta biblioteca; se n�o, escreva para a Free Software Foundation, Inc.,  }
{ no endere�o 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.          }
{ Voc� tamb�m pode obter uma copia da licen�a em:                              }
{ http://www.opensource.org/licenses/lgpl-license.php                          }

{ Daniel Sim�es de Almeida  -  daniel@djsystem.com.br  -  www.djsystem.com.br  }
{              Pra�a Anita Costa, 34 - Tatu� - SP - 18270-410                  }

{******************************************************************************}

{$I ACBr.inc}

unit ACBrIntegrador;

interface

uses
{$IFDEF MSWINDOWS}
 {$IFNDEF FPC}
  Windows,
 {$ENDIF}
{$ENDIF}
  Classes, SysUtils,
  pcnGerador, pcnLeitor, pcnVFPe, pcnVFPeW, pcnVFPeR,
  ACBrBase;

const
  cACBrIntgerador_Versao = '0.1.0' ;

type
  EComandoIntegradorException = class( Exception );
  EIntegradorException = class( Exception );

  TACBrIntegrador = class;

  { TComandoIntegrador }
  TComandoIntegrador = class
  private
    FOwner: TACBrIntegrador;
    FLeitor: TLeitor;
    FPastaInput: String;
    FPastaOutput: String;
    FTimeout: Integer;
    FErroTimeout: Boolean;
    procedure SetPastaInput(AValue: String);
    procedure SetPastaOutput(AValue: String);

  private
    function PegaResposta(Resp : String) : String;
    function AguardaArqResposta(numeroSessao: Integer) : String;
    procedure DoException( AMessage: String );

  public
    constructor Create( AOwner: TACBrIntegrador );
    destructor Destroy; override;

    function EnviaComando(numeroSessao: Integer; Nome, Comando : String; TimeOutComando : Integer = 0) : String;
  public
    property PastaInput  : String  read FPastaInput  write SetPastaInput;
    property PastaOutput : String  read FPastaOutput write SetPastaOutput;
    property Timeout     : Integer read FTimeout     write FTimeout default 30;
    property ErroTimeout : Boolean read FErroTimeout;
  end;

  TACBrIntegradorGetNumeroSessao = procedure(var NumeroSessao: Integer) of object ;

  { TACBrIntegrador }

  TACBrIntegrador = class(TACBrComponent)
  private
    FGerador: TGerador;
    FComandoIntegrador: TComandoIntegrador;
    FNomeMetodo: String;
    FNomeComponente: String;
    FNumeroSessao: Integer;
    FOnGetNumeroSessao: TACBrIntegradorGetNumeroSessao;
    FParametro: TParametro;
    FMetodo: TMetodo;
    FParametros: TStringList;
    FRetornoLst : TStringList ;

    function GetErroTimeout: Boolean;
    function GetPastaInput: String;
    function GetPastaOutput: String;
    function GetTimeout: Integer;
    procedure SetPastaInput(AValue: String);
    procedure SetPastaOutput(AValue: String);
    procedure SetTimeout(AValue: Integer);

  private
    fsArqLOG: String;
    fsOnGravarLog: TACBrGravarLog;
    function GerarArquivo: String;
    function GetAbout: String;
    function GetNumeroSessao: Integer;
    procedure GravaLog(AString : AnsiString ) ;
    procedure SetAbout(AValue: String);
    procedure DoException( AMessage: String );

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    procedure DoLog(AString : String ) ;

    function Enviar(AdicionarNumeroSessao: Boolean = True; Decode: Boolean = False): String;

    property NomeComponente: String read FNomeComponente write FNomeComponente;
    property NomeMetodo: String read FNomeMetodo write FNomeMetodo;
    property Parametros: TStringList read FParametros;

    property NumeroSessao: Integer read GetNumeroSessao;
    function GerarNumeroSessao: Integer;
    procedure SetNomeMetodo(NomeMetodo: String; Homologacao: Boolean);

    function EnviarPagamento(Pagamento: TEnviarPagamento): TRespostaPagamento;
    function EnviarStatusPagamento(StatusPagamento: TStatusPagamento): TRespostaStatusPagamento;
    function VerificarStatusValidador(AVerificarStatusValidador: TVerificarStatusValidador):
      TRespostaVerificarStatusValidador;
    function RespostaFiscal(ARespostaFiscal: TRespostaFiscal): TRetornoRespostaFiscal;

  published
    property About : String read GetAbout write SetAbout stored False ;
    property ArqLOG : String read fsArqLOG write fsArqLOG ;
    property OnGravarLog : TACBrGravarLog read fsOnGravarLog write fsOnGravarLog;

    property PastaInput  : String  read GetPastaInput    write SetPastaInput;
    property PastaOutput : String  read GetPastaOutput   write SetPastaOutput;
    property Timeout     : Integer read GetTimeout       write SetTimeout default 30;
    property OnGetNumeroSessao : TACBrIntegradorGetNumeroSessao read FOnGetNumeroSessao
       write FOnGetNumeroSessao;

    property ErroTimeout : Boolean read GetErroTimeout;
  end;


implementation

Uses
  dateutils, strutils,
  pcnConversao, synacode,
  ACBrUtil;

{ TComandoIntegrador }

constructor TComandoIntegrador.Create(AOwner: TACBrIntegrador);
begin
  FOwner := AOwner;
  FLeitor := TLeitor.Create;

  FPastaInput  := 'C:\Integrador\Input\';
  FPastaOutput := 'C:\Integrador\Output\';
  FTimeout     := 30;
  FErroTimeout := False;
end;

destructor TComandoIntegrador.Destroy;
begin
  FLeitor.Free;
  inherited Destroy;
end;

procedure TComandoIntegrador.SetPastaInput(AValue: String);
begin
  if FPastaInput = AValue then Exit;
  FPastaInput := PathWithDelim(AValue);
end;

procedure TComandoIntegrador.SetPastaOutput(AValue: String);
begin
  if FPastaOutput = AValue then Exit;
  FPastaOutput := PathWithDelim(AValue);
end;

function TComandoIntegrador.EnviaComando(numeroSessao: Integer; Nome, Comando: String; TimeOutComando : Integer = 0): String;
var
  LocTimeOut, ActualTime, TimeToRetry : TDateTime;
  NomeArquivoXml, RespostaIntegrador : String;
  ATimeout: Integer;

  function CriarXml( NomeArquivo, Comando: String): String;
  var
    NomeArquivoTmp, NomeArquivoXml: String;
  begin
    NomeArquivoTmp := ChangeFileExt(NomeArquivo, '.tmp');
    FOwner.DoLog('Criando arquivo: '+NomeArquivoTmp);
    WriteToFile(NomeArquivoTmp, Comando);

    if not FileExists(NomeArquivoTmp) then
      DoException('Erro ao criar o arquivo: '+NomeArquivoTmp);

    NomeArquivoXml := ChangeFileExt(NomeArquivoTmp,'.xml');
    FOwner.DoLog('Renomeando arquivo: '+NomeArquivoTmp+' para: '+NomeArquivoXml);
    if not RenameFile(NomeArquivoTmp, NomeArquivoXml) then
      DoException('Erro ao renomear o arquivo: '+ NomeArquivoTmp+' para: '+NomeArquivoXml);

    Result := NomeArquivoXml;
  end;

begin
  Result := '';
  FErroTimeout := False;

  NomeArquivoXml := CriarXml( FPastaInput + LowerCase(Nome) + '-' + IntToStr(numeroSessao),
                              Comando);
  ActualTime  := Now;
  TimeToRetry := IncSecond(ActualTime,5);
  if (TimeOutComando > 0) then
    ATimeout := TimeOutComando
  else
    ATimeout := FTimeout;

  if (ATimeout <= 0) then
    ATimeout := 30;

  LocTimeOut := IncSecond(ActualTime, ATimeout);

  RespostaIntegrador := AguardaArqResposta(numeroSessao);
  while EstaVazio(RespostaIntegrador) and (ActualTime < LocTimeOut) do
  begin
    Sleep(100);
    RespostaIntegrador := AguardaArqResposta(numeroSessao);
    ActualTime := Now;
    if ActualTime > TimeToRetry then //Caso arquivo ainda n�o tenha sido consumido ap�s 5 segundos, recria o arquivo
    begin
      TimeToRetry := IncSecond(ActualTime,5);
      if FilesExists(NomeArquivoXml) then
      begin
        try
          FOwner.DoLog('Apagando arquivo n�o processado: '+NomeArquivoXml);
          DeleteFile(NomeArquivoXml);
        except
        end;

        NomeArquivoXml := CriarXml( FPastaInput + LowerCase(Nome) +'-'+ IntToStr(numeroSessao) +
                                    '-' + FormatDateTime('HHNNSS', ActualTime),
                                    Comando);
      end;
    end;
  end;

  if FilesExists(NomeArquivoXml) then  // Apaga arquivo n�o tratado pelo Integrador
  begin
    FOwner.DoLog('Apagando arquivo: '+NomeArquivoXml);
    DeleteFile(NomeArquivoXml);
  end;

  if EstaVazio(RespostaIntegrador) then
  begin
    FErroTimeout := True;
    DoException('Sem Resposta do Integrador');
  end;

  FOwner.DoLog('RespostaIntegrador: '+RespostaIntegrador);

  Result := PegaResposta(RespostaIntegrador);
end;

function TComandoIntegrador.PegaResposta(Resp: String): String;
begin
  FLeitor.Arquivo := Resp;
  if FLeitor.rExtrai(1, 'retorno') <> '' then
    Result := FLeitor.rCampo(tcStr, 'retorno')
  else if FLeitor.rExtrai(1, 'Resposta') <> '' then
    Result := FLeitor.rCampo(tcStr, 'Resposta')
  else if FLeitor.rExtrai(1, 'Erro') <> '' then
    Result := FLeitor.Grupo
  else
    Result := Resp;

  if EstaVazio(Result) then
    Result := Resp;
end;

function TComandoIntegrador.AguardaArqResposta(numeroSessao: Integer): String;
var
  SL, SLArqResp : TStringList;
  I, J, MaxTentativas : Integer;
  Erro : Boolean;
  Arquivo: String;
begin
  FOwner.DoLog('AguardaArqResposta, sessao: '+IntToStr(numeroSessao));

  Result := '';
  SL := TStringList.Create;
  SLArqResp := TStringList.Create;
  try
    SLArqResp.Clear;
    FindFiles(PathWithDelim(FPastaOutput)+'*.xml',SLArqResp);
    Sleep(50); //Tentar evitar ler arquivo enquanto est� sendo escrito

    for I:=0  to SLArqResp.Count-1 do
    begin
      SL.Clear;

      try
        SL.LoadFromFile(SLArqResp[I]); //ERRO: Unable to open
        Arquivo := SL.Text;
      except
        J := 0;
        MaxTentativas := 5;
        while J < MaxTentativas do
        begin
          try
            Erro := False;
            Sleep(500);
            SL.LoadFromFile(SLArqResp[I]); //ERRO: Unable to open
            Arquivo := SL.Text;
          except
            Erro := True;
            if J = (MaxTentativas-1) then
              Arquivo := ''; //Caso n�o consigo abrir, retorna vazio
          end;
          if not Erro then
            Break;
          Inc(J);
        end;
      end;

      FLeitor.Arquivo := Arquivo;
      if FLeitor.rExtrai(1, 'Identificador') <> '' then
      begin
        if FLeitor.rCampo(tcInt, 'Valor') = numeroSessao then
        begin
          Result := Trim(FLeitor.Arquivo);
          DeleteFile(SLArqResp[I]);
          Exit;
        end;
      end;
    end;
  finally
    SLArqResp.Free;
    SL.Free;
  end;
end;

procedure TComandoIntegrador.DoException(AMessage: String);
begin
  FOwner.DoLog('EComandoIntegradorException: '+AMessage);
  raise EComandoIntegradorException.Create(AMessage);
end;

{ TACBrIntegrador }

constructor TACBrIntegrador.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FOnGetNumeroSessao := Nil;
  FGerador := TGerador.Create;
  FComandoIntegrador := TComandoIntegrador.Create(Self);
  FParametro := TParametro.Create(FGerador);
  FMetodo := TMetodo.Create(FGerador);
  FRetornoLst := TStringList.Create;
  FParametros := TStringList.Create;

  Clear;
end;

destructor TACBrIntegrador.Destroy;
begin
  FParametros.Free;
  FRetornoLst.Free;
  FMetodo.Free;
  FParametro.Free;
  FComandoIntegrador.Free;
  FGerador.Free;

  inherited Destroy;
end;

procedure TACBrIntegrador.Clear;
begin
  FNumeroSessao := 0;
  FNomeMetodo := '';
  FNomeComponente := '';
  FParametros.Clear;
end;

procedure TACBrIntegrador.DoLog(AString: String);
var
  Tratado: Boolean;
begin
  Tratado := False;
  if Assigned( fsOnGravarLog ) then
    fsOnGravarLog( AString, Tratado );

  if not Tratado then
    GravaLog( AString );
end;

function TACBrIntegrador.GetErroTimeout: Boolean;
begin
  Result := FComandoIntegrador.ErroTimeout;
end;

function TACBrIntegrador.GetPastaInput: String;
begin
  Result := FComandoIntegrador.PastaInput;
end;

procedure TACBrIntegrador.SetPastaInput(AValue: String);
begin
  FComandoIntegrador.PastaInput := AValue;
end;

function TACBrIntegrador.GetPastaOutput: String;
begin
  Result := FComandoIntegrador.PastaOutput;
end;

procedure TACBrIntegrador.SetPastaOutput(AValue: String);
begin
  FComandoIntegrador.PastaOutput := AValue;
end;

function TACBrIntegrador.GetTimeout: Integer;
begin
  Result := FComandoIntegrador.Timeout;
end;

procedure TACBrIntegrador.SetTimeout(AValue: Integer);
begin
  FComandoIntegrador.Timeout := AValue;
end;

function TACBrIntegrador.Enviar(AdicionarNumeroSessao: Boolean; Decode: Boolean
  ): String;
Var
  Resp, DadosIntegrador, NomeArq: String;
begin
  GerarNumeroSessao;

  if AdicionarNumeroSessao then
    FParametros.Insert(0, 'numeroSessao='+IntToStr(FNumeroSessao) );

  DadosIntegrador := GerarArquivo;

  if (FNomeMetodo = '') then
    DoException('NomeMetodo n�o definido');

  NomeArq := FNomeMetodo+'-'+FormatDateTime('yyyymmddhhnnss', Now);
  DoLog( 'Sess�o: '+IntToStr(FNumeroSessao)+', Dados: '+DadosIntegrador);

  Resp := FComandoIntegrador.EnviaComando( FNumeroSessao, NomeArq, DadosIntegrador );

  FRetornoLst.Delimiter := '|';
  {$IFDEF FPC}
   FRetornoLst.StrictDelimiter := True;
  {$ELSE}
   Resp := StringReplace(Resp, '"','', [rfReplaceAll]);
   Resp := '"' + StringReplace(Resp, FRetornoLst.Delimiter,
                            '"' + FRetornoLst.Delimiter + '"', [rfReplaceAll]) +
           '"';
  {$ENDIF}
  FRetornoLst.DelimitedText := Resp;

  if Decode and (FRetornoLst.Count >= 6) then
    Resp := DecodeBase64(FRetornoLst[6]);

  DoLog( 'Sess�o: '+IntToStr(FNumeroSessao)+', Resposta: '+Resp);
  Result :=  Resp;
end ;

function TACBrIntegrador.GerarArquivo: String;
var
  I: Integer;
  ParseCMD : Boolean;
  Param: String;
begin
  Result := '';
  FGerador.LayoutArquivoTXT.Clear;
  FGerador.ArquivoFormatoXML := '';
  FGerador.ArquivoFormatoTXT := '';

  FMetodo.GerarMetodo(FNumeroSessao, FNomeComponente, FNomeMetodo);

  for I := 0 to FParametros.Count-1 do
  begin
    Param := FParametros.ValueFromIndex[I];
    ParseCMD := (Pos('<![CDATA[',Param) <= 0);
    FParametro.GerarParametro( FParametros.Names[I], Param , tcStr, ParseCMD);
  end;

  FMetodo.FinalizarMetodo;

  Result := FGerador.ArquivoFormatoXML;
end;

function TACBrIntegrador.GetAbout: String;
begin
  Result := 'ACBrIntegrador Ver: '+cACBrIntgerador_Versao;
end;

procedure TACBrIntegrador.GravaLog(AString: AnsiString);
begin
  if (ArqLOG = '') then
    Exit;

  WriteLog( ArqLOG, FormatDateTime('dd/mm/yy hh:nn:ss:zzz',now) + ' - ' + AString );
end;

procedure TACBrIntegrador.SetAbout(AValue: String);
begin
  {}
end;

procedure TACBrIntegrador.DoException(AMessage: String);
begin
  DoLog('EIntegradorException: '+AMessage);
  raise EIntegradorException.Create(ACBrStr(AMessage));
end;

function TACBrIntegrador.GerarNumeroSessao: Integer;
begin
  FNumeroSessao := Random(999999);

  if Assigned( FOnGetNumeroSessao ) then
     FOnGetNumeroSessao( FNumeroSessao ) ;

  Result := FNumeroSessao;
end;

function TACBrIntegrador.GetNumeroSessao: Integer;
begin
  //if Assigned( FOnGetNumeroSessao ) then
  //   FOnGetNumeroSessao( FNumeroSessao ) ;

  Result := FNumeroSessao;
end;

procedure TACBrIntegrador.SetNomeMetodo(NomeMetodo: String; Homologacao: Boolean
  );
begin
  FNomeMetodo := IfThen(Homologacao,'H','')+NomeMetodo;
end;

function TACBrIntegrador.EnviarPagamento(Pagamento: TEnviarPagamento
  ): TRespostaPagamento;
var
  Comando, Resp : String;
begin
{$IFNDEF COMPILER23_UP}
  Result := Nil;
{$ENDIF}
  GerarNumeroSessao;

  Pagamento.Identificador := numeroSessao;
  Comando := Pagamento.AsXMLString;
  DoLog('EnviarPagamento( '+Comando+' )');

  Resp := FComandoIntegrador.EnviaComando( numeroSessao, 'EnviarPagamento', Comando);

  Result := TRespostaPagamento.Create;
  Result.AsXMLString := Resp;
end;

function TACBrIntegrador.EnviarStatusPagamento(
  StatusPagamento: TStatusPagamento): TRespostaStatusPagamento;
var
  Comando, Resp : String;
begin
{$IFNDEF COMPILER23_UP}
  Result := Nil;
{$ENDIF}
  GerarNumeroSessao;

  StatusPagamento.Identificador := numeroSessao;
  Comando := StatusPagamento.AsXMLString;
  DoLog('EnviarStatusPagamento( '+Comando+' )');

  Resp := FComandoIntegrador.EnviaComando(numeroSessao,'EnviarStatusPagamento',Comando);

  Result := TRespostaStatusPagamento.Create;
  Result.AsXMLString := Resp;
end;

function TACBrIntegrador.VerificarStatusValidador(
  AVerificarStatusValidador: TVerificarStatusValidador
  ): TRespostaVerificarStatusValidador;
var
  Comando, Resp : String;
begin
{$IFNDEF COMPILER23_UP}
  Result := Nil;
{$ENDIF}
  GerarNumeroSessao;

  AVerificarStatusValidador.Identificador := numeroSessao;
  Comando := AVerificarStatusValidador.AsXMLString;
  DoLog('VerificarStatusValidador( '+Comando+' )');

  Resp := FComandoIntegrador.EnviaComando(numeroSessao,'VerificarStatusValidador',Comando);

  Result := TRespostaVerificarStatusValidador.Create;
  Result.AsXMLString := Resp;
end;

function TACBrIntegrador.RespostaFiscal(
  ARespostaFiscal: TRespostaFiscal): TRetornoRespostaFiscal;
var
  Comando, Resp : String;
begin
{$IFNDEF COMPILER23_UP}
  Result := Nil;
{$ENDIF}
  GerarNumeroSessao;

  ARespostaFiscal.Identificador := numeroSessao;
  Comando := ARespostaFiscal.AsXMLString;
  DoLog('RespostaFiscal( '+Comando+' )');

  Resp := FComandoIntegrador.EnviaComando(numeroSessao,'RespostaFiscal',Comando);

  Result := TRetornoRespostaFiscal.Create;
  Result.AsXMLString := Resp;
end;

end.
