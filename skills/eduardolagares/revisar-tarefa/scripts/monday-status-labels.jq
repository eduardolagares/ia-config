# Entrada: array de colunas Monday → saída: array {column_id, column_title, labels[]}
# Uso: jq -f monday-status-labels.jq <<< "$columns_json"

def parse_settings($col):
  if ($col.settings | type) == "object" then $col.settings
  elif ($col.settings | type) == "string" and ($col.settings | length) > 0 then ($col.settings | fromjson)
  elif ($col.settings_str | type) == "string" and ($col.settings_str | length) > 0 then ($col.settings_str | fromjson)
  else null end;

def label_name($v):
  if ($v | type) == "string" then $v
  elif ($v | type) == "object" then ($v.label // $v.name // empty)
  else empty end;

def labels_from_settings($s; $source):
  ($s.labels // empty) as $raw
  | ($s.labels_colors // {}) as $colors
  | ($s.done_colors // []) as $done
  | ($s.labels_positions_v2 // {}) as $pos
  | if ($raw | type) == "array" then
      $raw
      | map(select(label_name(.) != "" and label_name(.) != null))
      | map({
          index: (.index // .id),
          id: (.id // .index),
          label: label_name(.),
          color: (.color // null),
          is_done: (.is_done // false),
          position: (.index // 0),
          source: $source
        })
    elif ($raw | type) == "object" then
      $raw
      | to_entries
      | map(select(label_name(.value) != "" and label_name(.value) != null))
      | map(
          .key as $k |
          ($k | if test("^[0-9]+$") then tonumber else null end) as $idx |
          {
            index: $idx,
            id: $idx,
            label: label_name(.value),
            color: ($colors[$k].var_name // $colors[$k].color // null),
            is_done: (if ($idx != null) then ($done | index($idx) != null) else false end),
            position: ($pos[$k] // $idx // 0),
            source: $source
          }
        )
    else [] end
  | sort_by(.position // .index // 0);

def status_columns_from($columns):
  $columns
  | map(select(.archived != true and .type == "status"))
  | map(. as $col |
      (parse_settings($col)) as $s |
      {
        column_id: $col.id,
        column_title: $col.title,
        column_type: $col.type,
        settings_source: (
          if ($col.settings | type) == "object" then "settings"
          elif ($col.settings | type) == "string" and ($col.settings | length) > 0 then "settings"
          else "settings_str" end
        ),
        labels: (
          if $s == null then []
          else labels_from_settings($s; (
            if ($col.settings != null) and (($col.settings | type) != "null") then "settings"
            else "settings_str" end
          ))
          end
        )
      }
    );

status_columns_from(.)
