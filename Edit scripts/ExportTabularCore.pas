(**
 * A collection of functions used when creating tabular dumps.
 *)
unit ExportTabularCore;


(**
 * Escapes [text] by escaping newlines and quotes and then surrounding it with quotes.
 *
 * @param text  the text to escape
 * @return a CSV-escaped version of [text]
 *)
function escapeCsvString(text: String): String;
begin
    result := text;
    result := stringReplace(result, #13 + #10, '\n', [rfReplaceAll]);
    result := stringReplace(result, #10, '\n', [rfReplaceAll]);
    result := stringReplace(result, '"', '""', [rfReplaceAll]);
    result := '"' + result + '"';
end;


end.
