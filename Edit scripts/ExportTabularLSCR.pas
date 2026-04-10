unit ExportTabularLSCR;

uses ExportCore,
     ExportTabularCore;


var ExportTabularLSCR_outputLines: TStringList;


function initialize(): Integer;
begin
    ExportTabularLSCR_outputLines := TStringList.create();
    ExportTabularLSCR_outputLines.add(
        '"File", ' +              // Name of the originating ESM
        '"Form ID", ' +           // Form ID
        '"Editor ID", ' +         // Editor ID
        '"Description", ' +       // (English) flavor text
        '"Background image", ' +  // Path to file displayed in background
        '"Foreground model"'      // Link to 'STAT' record displayed in foreground
    );
end;

function process(el: IInterface): Integer;
begin
    if signature(el) <> 'LSCR' then begin exit; end;

    _process(el);
end;

function _process(lscr: IInterface): Integer;
begin
    ExportTabularLSCR_outputLines.add(
        escapeCsvString(getFileName(getFile(lscr))) + ', ' +
        escapeCsvString(stringFormID(lscr)) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(lscr, 'EDID'))) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(lscr, 'DESC'))) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(lscr, 'BNAM'))) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(lscr, 'NNAM')))
    );
end;

function finalize(): Integer;
begin
    createDir('dumps/');
    ExportTabularLSCR_outputLines.saveToFile('dumps/LSCR.csv');
    ExportTabularLSCR_outputLines.free();
end;


end.
