unit ExportWikiBOOK;

uses ExportCore,
     ExportTabularCore,
     ExportWikiCore;


var ExportTabularFORTUNE_outputLines: TStringList;
var ExportWikiBOOK_outputLines: TStringList;


function initialize(): Integer;
begin
    ExportTabularFORTUNE_outputLines := TStringList.create();
    ExportTabularFORTUNE_outputLines.add('"Name", "Fortune"');

    ExportWikiBOOK_outputLines := TStringList.create();
end;

function process(el: IInterface): Integer;
begin
    if signature(el) <> 'BOOK' then begin exit; end;

    _process(el);
end;

function _process(book: IInterface): Integer;
var edid: String;
    full: String;
    desc: String;
begin
    edid := getEditValue(elementBySignature(book, 'EDID'));
    full := getEditValue(elementBySignature(book, 'FULL'));
    desc := trim(getEditValue(elementBySignature(book, 'DESC')));

    if strEquals(leftStr(edid, 17), 'ATX_Book_Fortunes') then begin
        ExportTabularFORTUNE_outputLines.add(escapeCsvString(full) + ', ' + stripHtmlTags(escapeCsvString(desc)));
    end;

    ExportWikiBOOK_outputLines.add('==[' + getFileName(getFile(book)) + '] ' + full + '==');
    ExportWikiBOOK_outputLines.add('Form ID:      ' + stringFormID(book));
    ExportWikiBOOK_outputLines.add('Editor ID:    ' + edid);
    ExportWikiBOOK_outputLines.add('Weight:       ' + getEditValue(elementByPath(book, 'DATA\Weight')));
    ExportWikiBOOK_outputLines.add('Value:        ' + getEditValue(elementByPath(book, 'DATA\Value')));
    ExportWikiBOOK_outputLines.add('Can be taken: ' + canBeTakenString(book));
    ExportWikiBOOK_outputLines.add('Transcript:' + #10 + asWikiTranscript(desc));
    ExportWikiBOOK_outputLines.add(#10);
end;

function finalize(): Integer;
begin
    createDir('dumps/');

    ExportTabularFORTUNE_outputLines.saveToFile('dumps/FORTUNE.csv');
    ExportTabularFORTUNE_outputLines.free();

    ExportWikiBOOK_outputLines.saveToFile('dumps/BOOK.wiki');
    ExportWikiBOOK_outputLines.free();
end;


function canBeTakenString(book: IInterface): String;
var flags: String;
    pickUpFlag: String;
begin
    flags := getEditValue(elementByPath(book, 'DNAM\Flags'));
    if length(flags) = 1 then begin
        result := 'no';
    end;

    pickUpFlag := copy(flags, 2, 1);
    if pickUpFlag = '0' then begin
        result := 'yes';
    end else begin
        result := 'no';
    end;
end;

function stripHtmlTags(text: String): String;
var remainder: String;
    remainder2: String;
begin
    addMessage(text);
    { Note: This method does not work with nested HTML tags! }
    { TODO: This function currently gets stuck in an infinite loop, unfortunately... }

    remainder := text;
    result := '';

    while strLen(remainder) > 0 do begin
        if strLComp(remainder, '<', 1) = 0 then begin
            remainder := strScan(remainder, '>');
            delete(remainder, 1, 1);
        end else begin
            remainder2 := strScan(remainder, '<');
            if strLen(remainder2) = 0 then begin
                result := strCat(result, remainder);
                break;
            end else begin
                result := result + leftStr(remainder, strLen(remainder) - strLen(remainder2));
                remainder := remainder2;
            end;
        end;
    end;
end;

function asWikiTranscript(text: String): String;
begin
    if text = '' then begin
        result := 'No transcript';
    end else begin
        result := '{{Transcript|text=' + #10 + escapeWiki(text) + #10 + '}}';
    end;
end;


end.
