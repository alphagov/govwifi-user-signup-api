class Gdpr::Gateway::Userdetails
  def delete_users
    DB.run('DELETE FROM userdetails
        WHERE (last_login < DATE_SUB(NOW(), INTERVAL 12 MONTH)
        OR (last_login IS NULL AND created_at < DATE_SUB(NOW(), INTERVAL 12 MONTH)))
        AND username != "HEALTH"')
  end

  def obfusticate_sponsors
    DB.run("UPDATE userdetails ud1
        LEFT JOIN userdetails as ud2 ON ud1.sponsor = ud2.contact
        SET ud1.sponsor = REPLACE(ud1.sponsor, SUBSTRING_INDEX(ud1.sponsor, '@', '1'), 'user')
        WHERE ud2.username IS NULL")
  end
end
