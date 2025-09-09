VAR has_journal = false
VAR has_camera = true

{has_journal == true and has_camera == true: You got everything}
{has_journal == true and has_camera == false: You only have the journal}
{has_journal == false and has_camera == true: You only have the camera}
{has_journal == false and has_camera == false: You don't have anything}

{
-has_journal and has_camera: You have everything
-has_journal: You only have the journal
-has_camera: You only have the camera
-else: You don't have anything
}

->END