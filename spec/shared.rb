def write_email_to_s3(text_part: nil, html_part: nil, body: nil, bucket_name: nil, object_key: nil)
  mail = Mail.new
  mail.parts << Mail::Part.new(body: text_part) if text_part
  mail.parts << Mail::Part.new(content_type: "text/html; charset=UTF-8", body: html_part) if html_part
  mail.body = body if body
  Services.s3_client.put_object(bucket: bucket_name, key: object_key, body: mail.to_s)
end
