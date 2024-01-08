use ig_clone;
--------------------------------------------------------------------------------------------------

-- 1. How many times does the average user post?

WITH Avg_Count AS(
SELECT user_id, COUNT(id) AS p_count FROM photos
GROUP BY user_id 
)
SELECT AVG(p_count) AS Average_User_Post from Avg_Count;

---------------------------------------------------------------------------------------------------------

-- 2. Find the top 5 most used hashtags.

-- To find - Top hashtags
# Here TC = TAG COUNT. 

WITH TC AS (
SELECT tag_id,count(photo_id) AS tag_count FROM photo_tags
GROUP BY tag_id
ORDER BY count(photo_id) DESC)
SELECT tag_name, tag_count FROM tags t LEFT JOIN TC
ON t.id = TC.tag_id
ORDER BY tag_count DESC
LIMIT 5;

---------------------------------------------------------------------------------------------------------

-- 3. Find users who have liked every single photo on the site.

-- To find - users who liked every photo 

# Here PC = Photo_Count

WITH PC AS (
SELECT user_id,COUNT(photo_id) AS pidcount FROM likes
GROUP BY user_id
HAVING COUNT(photo_id) IN (SELECT COUNT(*) FROM photos)
)
SELECT user_id, username, PC.pidcount FROM PC JOIN users u
ON u.id = PC.user_id
;

---------------------------------------------------------------------------------------------------------

-- 4. Retrieve a list of users along with their usernames and the rank of their
--    account creation, ordered by the creation date in ascending order.

-- To find - Ranking users acc. to a/c creation in asc order

SELECT username, created_at,
RANK() OVER (ORDER BY created_at) AS Rank_of_AC_created FROM users;

---------------------------------------------------------------------------------------------------------

-- 5. List the comments made on photos with their comment texts, photo URLs, and usernames
--    of users who posted the comments. Include the comment count for each photo

-- To find - Count of comments on each photo with other details like who commented what

WITH comment_details AS (
SELECT comment_text,p.id, photo_id, image_url, u.username
FROM comments c JOIN photos p 
ON c.photo_id = p.id
JOIN users u 
ON u.id = c.user_id
)
SELECT comment_text, image_url, username, id,
COUNT(comment_text) OVER (PARTITION BY photo_id ORDER BY photo_id) AS comments_count_per_photo
FROM comment_details;

---------------------------------------------------------------------------------------------------------

-- 6. For each tag, show the tag name and the number of photos associated with that tag.
--    Rank the tags by the number of photos in descending order.

-- To find - Tags count in desc order.

-- Here TC = tag_count CTE

WITH TC AS (
SELECT tag_id, COUNT(photo_id) AS tag_count FROM photo_tags
GROUP BY tag_id)
SELECT tag_name, tag_count,
RANK() OVER (ORDER BY tag_count DESC) AS photo_tag_rank,
DENSE_RANK() OVER (ORDER BY tag_count DESC) AS photo_tag_denserank
FROM tags t JOIN TC 
ON t.id = TC.tag_id
;

---------------------------------------------------------------------------------------------------------

-- 7. List the usernames of users who have posted photos along with the count of photos
--    they have posted. Rank them by the number of photos in descending order.

-- To find - Ranking the users acc. to the photos they have posted in desc.

-- Here PC = Photo Count CTE

WITH pc AS (
SELECT user_id, COUNT(*) AS photo_count FROM photos
GROUP BY user_id
ORDER BY COUNT(*) DESC)
SELECT id, username, photo_count,
RANK () OVER (ORDER BY photo_count DESC) AS pc_rank,
DENSE_RANK () OVER (ORDER BY photo_count DESC) AS pc_dense_rank
FROM users u LEFT JOIN pc
ON u.id = pc.user_id 
;

---------------------------------------------------------------------------------------------------------

-- 8. Display the username of each user along with the creation date of their first posted
--    photo and the creation date of their next posted photo.

-- To find - Next posting date of a photo by the user

-- Here PCD = Photo Creation Details CTE

WITH PCD AS (
SELECT u.username, p.user_id, p.created_at AS first_photo_date,
LEAD(p.created_at) OVER (PARTITION BY p.user_id ORDER BY p.created_at) AS next_photo_date
FROM photos p
JOIN users u
ON p.user_id = u.id
)
SELECT user_id, username, first_photo_date, next_photo_date FROM PCD;

---------------------------------------------------------------------------------------------------------

-- 9. For each comment, show the comment text, the username of the commenter, and the
--    comment text of the previous comment made on the same photo.

-- To find - comment, who comment that? for each photo along with the previous comment made on the same photo

WITH comments_text AS (
SELECT comment_text, photo_id, user_id, username FROM comments c 
JOIN users u 
ON c.user_id = u.id
)
SELECT photo_id,comment_text, username,
LAG(comment_text) OVER (PARTITION BY photo_id ORDER BY user_id) AS previous_comment
FROM comments_text
;

---------------------------------------------------------------------------------------------------------

-- 10. Show the username of each user along with the number of photos they have posted and
--     the number of photos posted by the user before them and after them, based on the
--     creation date.

-- To find - Total photos posted by users acc. to their creation date and no. of photos posted brfore and after them 

-- CP = Count of photos CTE

WITH CP AS (
SELECT user_id,COUNT(id) AS tot_photos FROM photos
GROUP BY user_id)
SELECT username, tot_photos,
LAG(tot_photos) OVER (ORDER BY created_at) AS user_before,
LEAD(tot_photos) OVER (ORDER BY created_at) AS user_after 
FROM CP JOIN users u 
ON CP.user_id = u.id
;

---------------------------------------------------------------------------------------------------------

