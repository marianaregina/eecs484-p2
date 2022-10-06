package project2;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.ResultSet;
import java.util.ArrayList;

/*
    The StudentFakebookOracle class is derived from the FakebookOracle class and implements
    the abstract query functions that investigate the database provided via the <connection>
    parameter of the constructor to discover specific information.
*/
public final class StudentFakebookOracle extends FakebookOracle {
    // [Constructor]
    // REQUIRES: <connection> is a valid JDBC connection
    public StudentFakebookOracle(Connection connection) {
        oracle = connection;
    }

    @Override
    // Query 0
    // -----------------------------------------------------------------------------------
    // GOALS: (A) Find the total number of users for which a birth month is listed
    //        (B) Find the birth month in which the most users were born
    //        (C) Find the birth month in which the fewest users (at least one) were born
    //        (D) Find the IDs, first names, and last names of users born in the month
    //            identified in (B)
    //        (E) Find the IDs, first names, and last name of users born in the month
    //            identified in (C)
    //
    // This query is provided to you completed for reference. Below you will find the appropriate
    // mechanisms for opening up a statement, executing a query, walking through results, extracting
    // data, and more things that you will need to do for the remaining nine queries
    public BirthMonthInfo findMonthOfBirthInfo() throws SQLException {
        try (Statement stmt = oracle.createStatement(FakebookOracleConstants.AllScroll,
                FakebookOracleConstants.ReadOnly)) {
            // Step 1
            // ------------
            // * Find the total number of users with birth month info
            // * Find the month in which the most users were born
            // * Find the month in which the fewest (but at least 1) users were born
            ResultSet rst = stmt.executeQuery(
                    "SELECT COUNT(*) AS Birthed, Month_of_Birth " + // select birth months and number of uses with that birth month
                            "FROM " + UsersTable + " " + // from all users
                            "WHERE Month_of_Birth IS NOT NULL " + // for which a birth month is available
                            "GROUP BY Month_of_Birth " + // group into buckets by birth month
                            "ORDER BY Birthed DESC, Month_of_Birth ASC"); // sort by users born in that month, descending; break ties by birth month

            int mostMonth = 0;
            int leastMonth = 0;
            int total = 0;
            while (rst.next()) { // step through result rows/records one by one
                if (rst.isFirst()) { // if first record
                    mostMonth = rst.getInt(2); //   it is the month with the most
                }
                if (rst.isLast()) { // if last record
                    leastMonth = rst.getInt(2); //   it is the month with the least
                }
                total += rst.getInt(1); // get the first field's value as an integer
            }
            BirthMonthInfo info = new BirthMonthInfo(total, mostMonth, leastMonth);

            // Step 2
            // ------------
            // * Get the names of users born in the most popular birth month
            rst = stmt.executeQuery(
                    "SELECT User_ID, First_Name, Last_Name " + // select ID, first name, and last name
                            "FROM " + UsersTable + " " + // from all users
                            "WHERE Month_of_Birth = " + mostMonth + " " + // born in the most popular birth month
                            "ORDER BY User_ID"); // sort smaller IDs first

            while (rst.next()) {
                info.addMostPopularBirthMonthUser(new UserInfo(rst.getLong(1), rst.getString(2), rst.getString(3)));
            }

            // Step 3
            // ------------
            // * Get the names of users born in the least popular birth month
            rst = stmt.executeQuery(
                    "SELECT User_ID, First_Name, Last_Name " + // select ID, first name, and last name
                            "FROM " + UsersTable + " " + // from all users
                            "WHERE Month_of_Birth = " + leastMonth + " " + // born in the least popular birth month
                            "ORDER BY User_ID"); // sort smaller IDs first

            while (rst.next()) {
                info.addLeastPopularBirthMonthUser(new UserInfo(rst.getLong(1), rst.getString(2), rst.getString(3)));
            }

            // Step 4
            // ------------
            // * Close resources being used
            rst.close();
            stmt.close(); // if you close the statement first, the result set gets closed automatically

            return info;

        } catch (SQLException e) {
            System.err.println(e.getMessage());
            return new BirthMonthInfo(-1, -1, -1);
        }
    }

    @Override
    // Query 1
    // -----------------------------------------------------------------------------------
    // GOALS: (A) The first name(s) with the most letters
    //        (B) The first name(s) with the fewest letters
    //        (C) The first name held by the most users
    //        (D) The number of users whose first name is that identified in (C)
    public FirstNameInfo findNameInfo() throws SQLException {
        try (Statement stmt = oracle.createStatement(FakebookOracleConstants.AllScroll,
                FakebookOracleConstants.ReadOnly)) {
            /*
                EXAMPLE DATA STRUCTURE USAGE
                ============================================
                FirstNameInfo info = new FirstNameInfo();
                info.addLongName("Aristophanes");
                info.addLongName("Michelangelo");
                info.addLongName("Peisistratos");
                info.addShortName("Bob");
                info.addShortName("Sue");
                info.addCommonName("Harold");
                info.addCommonName("Jessica");
                info.setCommonNameCount(42);
                return info;
            */
            FirstNameInfo info = new FirstNameInfo();   // data structure for output

            ResultSet rst = stmt.executeQuery(
                "SELECT LENGTH(First_Name) AS len " +  // length of first name
                "FROM " + UsersTable + " " +    // from all users
                "ORDER BY len DESC");

            int lenLongest = 0;     // length of longest name
            int lenShortest = 0;    // length of shortest name
            while (rst.next()) { // step through result rows/records one by one
                if (rst.isFirst()) { // if first record
                    lenLongest = rst.getInt(1); //   it is the shortest
                }
                if (rst.isLast()) { // if last record
                    lenShortest = rst.getInt(1); //   it is the longest
                }
            }

            // -- Select all names with longest length in alphabetical order
            rst = stmt.executeQuery(
                "SELECT DISTINCT First_Name " +
                "FROM " + UsersTable + " " +
                "WHERE LENGTH(First_Name) = " + lenLongest + " " +
                "ORDER BY First_Name ASC");
            
            while (rst.next()) {    // add all longest names
                info.addLongName(rst.getString(1));
            }

            // -- Select all names with shortest length in alphabetical order
            rst = stmt.executeQuery(
                "SELECT DISTINCT First_Name " +
                "FROM " + UsersTable + " " +
                "WHERE LENGTH(First_Name) = " + lenShortest + " " +
                "ORDER BY First_Name ASC");
            
            while (rst.next()) {
                info.addShortName(rst.getString(1));
            }
            
            // -- Get frequency of most common first name
            rst = stmt.executeQuery(
                "SELECT * FROM ( " +
                "SELECT COUNT(*) AS nameCount " +
                "FROM " + UsersTable + " " +
                "GROUP BY First_Name " +
                "ORDER BY nameCount DESC " +
                ") WHERE ROWNUM <=1");

            int commonCount = 0;
            while (rst.next()) {
                commonCount = rst.getInt(1);
            }
            info.setCommonNameCount(commonCount);
            
            // -- Get most common first name
            rst = stmt.executeQuery(
                "SELECT First_Name FROM ( " +
                "SELECT First_Name, COUNT(*) AS nameCount " +
                "FROM " + UsersTable + " " +
                "GROUP BY First_Name " +
                "ORDER BY nameCount DESC " +
                ") WHERE nameCount = " + commonCount + " " +
                "ORDER BY First_Name ASC");

            while (rst.next()) {
                info.addCommonName(rst.getString(1));
            }
            // * Close resources being used
            rst.close();
            stmt.close(); // if you close the statement first, the result set gets closed automatically

            return info; // placeholder for compilation
        } catch (SQLException e) {
            System.err.println(e.getMessage());
            return new FirstNameInfo();
        }
    }

    @Override
    // Query 2
    // -----------------------------------------------------------------------------------
    // GOALS: (A) Find the IDs, first names, and last names of users without any friends
    //
    // Be careful! Remember that if two users are friends, the Friends table only contains
    // the one entry (U1, U2) where U1 < U2.
    public FakebookArrayList<UserInfo> lonelyUsers() throws SQLException {
        FakebookArrayList<UserInfo> results = new FakebookArrayList<UserInfo>(", ");

        try (Statement stmt = oracle.createStatement(FakebookOracleConstants.AllScroll,
                FakebookOracleConstants.ReadOnly)) {
            /*
                EXAMPLE DATA STRUCTURE USAGE
                ============================================
                UserInfo u1 = new UserInfo(15, "Abraham", "Lincoln");
                UserInfo u2 = new UserInfo(39, "Margaret", "Thatcher");
                results.add(u1);
                results.add(u2);
            */
            ResultSet rst = stmt.executeQuery(
                "SELECT U.USER_ID, U.First_Name, U.Last_Name " +
                "FROM " + UsersTable + " U " +
                "LEFT JOIN (" +
                "SELECT p1.USER_ID " +
                "FROM " + UsersTable + " p1 " +
                "MINUS " +
                "SELECT DISTINCT f1.USER1_ID " +
                "FROM " + FriendsTable + " f1 " +
                "MINUS " +
                "SELECT DISTINCT f2.USER2_ID " +
                "FROM " + FriendsTable + " f2 " +
                ") have_no_friends " +
                "ON have_no_friends.USER_ID = U.USER_ID " +
                "ORDER BY U.USER_ID ASC");
            
            while (rst.next()) {
                int tempId = rst.getInt(1);
                String tempFirst = rst.getString(2);
                String tempLast = rst.getString(3);
                UserInfo u1 = new UserInfo(tempId, tempFirst, tempLast);
                results.add(u1);
            }

            // * Close resources being used
            rst.close();
            stmt.close(); // if you close the statement first, the result set gets closed automatically
        } catch (SQLException e) {
            System.err.println(e.getMessage());
        }

        return results;
    }

    @Override
    // Query 3
    // -----------------------------------------------------------------------------------
    // GOALS: (A) Find the IDs, first names, and last names of users who no longer live
    //            in their hometown (i.e. their current city and their hometown are different)
    public FakebookArrayList<UserInfo> liveAwayFromHome() throws SQLException {
        FakebookArrayList<UserInfo> results = new FakebookArrayList<UserInfo>(", ");

        try (Statement stmt = oracle.createStatement(FakebookOracleConstants.AllScroll,
                FakebookOracleConstants.ReadOnly)) {
            /*
                EXAMPLE DATA STRUCTURE USAGE
                ============================================
                UserInfo u1 = new UserInfo(9, "Meryl", "Streep");
                UserInfo u2 = new UserInfo(104, "Tom", "Hanks");
                results.add(u1);
                results.add(u2);
            */
            ResultSet rst = stmt.executeQuery(
                "SELECT U.USER_ID, U.First_Name, U.Last_Name " +
                "FROM " + UsersTable + " U " +
                "LEFT JOIN " + CurrentCitiesTable + " C " +
                "ON (U.USER_ID = C.USER_ID) " +
                "LEFT JOIN " + HometownCitiesTable + " H " +
                "ON (U.USER_ID = H.USER_ID) " +
                "WHERE C.CURRENT_CITY_ID IS NOT NULL " +
                "AND H.HOMETOWN_CITY_ID IS NOT NULL " +
                "AND C.CURRENT_CITY_ID != H.HOMETOWN_CITY_ID " +
                "ORDER BY U.USER_ID ASC");

            while (rst.next()) {
                int tempId = rst.getInt(1);
                String tempFirst = rst.getString(2);
                String tempLast = rst.getString(3);
                UserInfo u1 = new UserInfo(tempId, tempFirst, tempLast);
                results.add(u1);
            }

            // * Close resources being used
            rst.close();
            stmt.close();
        } catch (SQLException e) {
            System.err.println(e.getMessage());
        }

        return results;
    }

    @Override
    // Query 4
    // -----------------------------------------------------------------------------------
    // GOALS: (A) Find the IDs, links, and IDs and names of the containing album of the top
    //            <num> photos with the most tagged users
    //        (B) For each photo identified in (A), find the IDs, first names, and last names
    //            of the users therein tagged
    public FakebookArrayList<TaggedPhotoInfo> findPhotosWithMostTags(int num) throws SQLException {
        FakebookArrayList<TaggedPhotoInfo> results = new FakebookArrayList<TaggedPhotoInfo>("\n");

        try (Statement stmt = oracle.createStatement(FakebookOracleConstants.AllScroll,
                FakebookOracleConstants.ReadOnly)) {
            /*
                EXAMPLE DATA STRUCTURE USAGE
                ============================================
                PhotoInfo p = new PhotoInfo(80, 5, "www.photolink.net", "Winterfell S1");
                UserInfo u1 = new UserInfo(3901, "Jon", "Snow");
                UserInfo u2 = new UserInfo(3902, "Arya", "Stark");
                UserInfo u3 = new UserInfo(3903, "Sansa", "Stark");
                TaggedPhotoInfo tp = new TaggedPhotoInfo(p);
                tp.addTaggedUser(u1);
                tp.addTaggedUser(u2);
                tp.addTaggedUser(u3);
                results.add(tp);
            */
        } catch (SQLException e) {
            System.err.println(e.getMessage());
        }

        return results;
    }

    @Override
    // Query 5
    // -----------------------------------------------------------------------------------
    // GOALS: (A) Find the IDs, first names, last names, and birth years of each of the two
    //            users in the top <num> pairs of users that meet each of the following
    //            criteria:
    //              (i) same gender
    //              (ii) tagged in at least one common photo
    //              (iii) difference in birth years is no more than <yearDiff>
    //              (iv) not friends
    //        (B) For each pair identified in (A), find the IDs, links, and IDs and names of
    //            the containing album of each photo in which they are tagged together
    public FakebookArrayList<MatchPair> matchMaker(int num, int yearDiff) throws SQLException {
        FakebookArrayList<MatchPair> results = new FakebookArrayList<MatchPair>("\n");

        try (Statement stmt = oracle.createStatement(FakebookOracleConstants.AllScroll,
                FakebookOracleConstants.ReadOnly)) {
            /*
            EXAMPLE DATA STRUCTURE USAGE
            ============================================
            UserInfo u1 = new UserInfo(93103, "Romeo", "Montague");
            UserInfo u2 = new UserInfo(93113, "Juliet", "Capulet");
            MatchPair mp = new MatchPair(u1, 1597, u2, 1597);
            PhotoInfo p = new PhotoInfo(167, 309, "www.photolink.net", "Tragedy");
            mp.addSharedPhoto(p);
            results.add(mp);
            */
            ResultSet rst = stmt.executeQuery(
                "CREATE VIEW pairs AS " +
                "SELECT u1.USER_ID AS USER1_ID, u2.USER_ID AS USER2_ID " +
                "FROM " + UsersTable + " u1, " + UsersTable + " u2 " +
                "WHERE (abs(u1.YEAR_OF_BIRTH - u2.YEAR_OF_BIRTH) <= 2) " +
                "AND (u1.GENDER = u2.GENDER) " +
                "AND (u1.USER_ID < u2.USER_ID) " +
                "AND (u1.USER_ID != u2.USER_ID)");

            rst = stmt.executeQuery(
                "CREATE VIEW already_friends AS " +
                "SELECT p.USER1_ID AS USER1_ID, p.USER2_ID AS USER2_ID " +
                "FROM pairs p, " + FriendsTable + " f " +
                "WHERE ((p.USER1_ID = f.USER1_ID) " +
                "AND (p.USER2_ID = f.USER2_ID))");

            rst = stmt.executeQuery(
                "SELECT * FROM pairs p MINUS " +
                "SELECT * FROM already_friends");

            rst = stmt.executeQuery(
                "CREATE VIEW tag_photos AS " +
                "SELECT pairs.USER1_ID AS USER1_ID, pairs.USER2_ID AS USER2_ID, " +
                "T1.TAG_PHOTO_ID AS PHOTO_ID, P.PHOTO_LINK AS PHOTO_LINK, " +
                "A.ALBUM_ID AS ALBUM_ID, A.ALBUM_NAME AS ALBUM_NAME " +
                "FROM pairs, " + TagsTable + " T2 " + TagsTable + " T1 " +
                "LEFT JOIN " + PhotosTable + " P ON T1.TAG_PHOTO_ID = P.PHOTO_ID " +
                "LEFT JOIN " + AlbumsTable + " A ON P.ALBUM_ID = A.ALBUM_ID " +
                "WHERE T1.TAG_PHOTO_ID = T2.TAG_PHOTO_ID " +
                "AND T1.TAG_SUBJECT_ID = pairs.USER1_ID " +
                "AND T2.TAG_SUBJECT_ID = pairs.USER2_ID ");
        
            rst = stmt.executeQuery(
                "CREATE VIEW final_pairs AS " +
                "SELECT * FROM ( " +
                "SELECT p.USER1_ID, p.USER2_ID " +
                "FROM tag_photos t " +
                "LEFT JOIN pairs p " +
                "ON (t.USER1_ID = p.USER1_ID AND t.USER2_ID = p.USER2_ID) " +
                "WHERE t.PHOTO_ID IS NOT NULL " +
                "GROUP BY (p.USER1_ID, p.USER2_ID) " +
                "ORDER BY COUNT(*) DESC, USER1_ID ASC, USER2_ID DESC) " +
                "WHERE ROWNUM <= 2");
            
            rst = stmt.executeQuery(
                "SELECT fp.USER1_ID, fp.USER2_ID, " +
                "t.PHOTO_ID, t.PHOTO_LINK, t.ALBUM_ID, t.ALBUM_NAME, " +
                "u1.First_Name, u1.Last_Name, u1.YEAR_OF_BIRTH, " +
                "u2.First_Name, u2.Last_Name, u2.YEAR_OF_BIRTH " +
                "FROM final_pairs fp " +
                "LEFT JOIN " + UsersTable + " u1 " +
                "ON (u1.USER_ID = fp.USER1_ID)" +
                "LEFT JOIN " + UsersTable + " u2 " +
                "ON (u2.USER_ID = fp.USER2_ID) " +
                "LEFT JOIN tag_photos t " +
                "ON (t.USER1_ID = fp.USER1_ID AND t.USER2_ID = fp.USER2_ID) ");

            while (rst.next()) {
                int user1Id = rst.getInt(1);
                int user2Id = rst.getInt(2);
                int photoId = rst.getInt(3);
                String link = rst.getString(4);
                int albumId = rst.getInt(5);
                String albumName = rst.getString(6);
                String user1First = rst.getString(7);
                String user1Last = rst.getString(8);
                int user1Year = rst.getInt(9);
                String user2First = rst.getString(10);
                String user2Last = rst.getString(11);
                int user2Year = rst.getInt(12);

                UserInfo u1 = new UserInfo(user1Id, user1First, user1Last);
                UserInfo u2 = new UserInfo(user2Id, user2First, user2Last);
                MatchPair mp = new MatchPair(u1, user1Year, u2, user2Year);
                PhotoInfo p = new PhotoInfo(photoId, albumId, link, albumName);
                mp.addSharedPhoto(p);
                results.add(mp);
            }

            // Drop views
            rst = stmt.executeQuery("DROP VIEW pairs");
            rst = stmt.executeQuery("DROP VIEW already_friends");
            rst = stmt.executeQuery("DROP VIEW tag_photos");
            rst = stmt.executeQuery("DROP VIEW final_pairs");

            // * Close resources being used
            rst.close();
            stmt.close();

            return results;
        } catch (SQLException e) {
            System.err.println(e.getMessage());
        }

        return results;
    }

    @Override
    // Query 6
    // -----------------------------------------------------------------------------------
    // GOALS: (A) Find the IDs, first names, and last names of each of the two users in
    //            the top <num> pairs of users who are not friends but have a lot of
    //            common friends
    //        (B) For each pair identified in (A), find the IDs, first names, and last names
    //            of all the two users' common friends
    public FakebookArrayList<UsersPair> suggestFriends(int num) throws SQLException {
        FakebookArrayList<UsersPair> results = new FakebookArrayList<UsersPair>("\n");

        try (Statement stmt = oracle.createStatement(FakebookOracleConstants.AllScroll,
                FakebookOracleConstants.ReadOnly)) {
            /*
                EXAMPLE DATA STRUCTURE USAGE
                ============================================
                UserInfo u1 = new UserInfo(16, "The", "Hacker");
                UserInfo u2 = new UserInfo(80, "Dr.", "Marbles");
                UserInfo u3 = new UserInfo(192, "Digit", "Le Boid");
                UsersPair up = new UsersPair(u1, u2);
                up.addSharedFriend(u3);
                results.add(up);
            */
        } catch (SQLException e) {
            System.err.println(e.getMessage());
        }

        return results;
    }

    @Override
    // Query 7
    // -----------------------------------------------------------------------------------
    // GOALS: (A) Find the name of the state or states in which the most events are held
    //        (B) Find the number of events held in the states identified in (A)
    public EventStateInfo findEventStates() throws SQLException {
        try (Statement stmt = oracle.createStatement(FakebookOracleConstants.AllScroll,
                FakebookOracleConstants.ReadOnly)) {
            /*
                EXAMPLE DATA STRUCTURE USAGE
                ============================================
                EventStateInfo info = new EventStateInfo(50);
                info.addState("Kentucky");
                info.addState("Hawaii");
                info.addState("New Hampshire");
                return info;
            */
            return new EventStateInfo(-1); // placeholder for compilation
        } catch (SQLException e) {
            System.err.println(e.getMessage());
            return new EventStateInfo(-1);
        }
    }

    @Override
    // Query 8
    // -----------------------------------------------------------------------------------
    // GOALS: (A) Find the ID, first name, and last name of the oldest friend of the user
    //            with User ID <userID>
    //        (B) Find the ID, first name, and last name of the youngest friend of the user
    //            with User ID <userID>
    public AgeInfo findAgeInfo(long userID) throws SQLException {
        try (Statement stmt = oracle.createStatement(FakebookOracleConstants.AllScroll,
                FakebookOracleConstants.ReadOnly)) {
            /*
                EXAMPLE DATA STRUCTURE USAGE
                ============================================
                UserInfo old = new UserInfo(12000000, "Galileo", "Galilei");
                UserInfo young = new UserInfo(80000000, "Neil", "deGrasse Tyson");
                return new AgeInfo(old, young);
            */
            return new AgeInfo(new UserInfo(-1, "UNWRITTEN", "UNWRITTEN"), new UserInfo(-1, "UNWRITTEN", "UNWRITTEN")); // placeholder for compilation
        } catch (SQLException e) {
            System.err.println(e.getMessage());
            return new AgeInfo(new UserInfo(-1, "ERROR", "ERROR"), new UserInfo(-1, "ERROR", "ERROR"));
        }
    }

    @Override
    // Query 9
    // -----------------------------------------------------------------------------------
    // GOALS: (A) Find all pairs of users that meet each of the following criteria
    //              (i) same last name
    //              (ii) same hometown
    //              (iii) are friends
    //              (iv) less than 10 birth years apart
    public FakebookArrayList<SiblingInfo> findPotentialSiblings() throws SQLException {
        FakebookArrayList<SiblingInfo> results = new FakebookArrayList<SiblingInfo>("\n");

        try (Statement stmt = oracle.createStatement(FakebookOracleConstants.AllScroll,
                FakebookOracleConstants.ReadOnly)) {
            /*
                EXAMPLE DATA STRUCTURE USAGE
                ============================================
                UserInfo u1 = new UserInfo(81023, "Kim", "Kardashian");
                UserInfo u2 = new UserInfo(17231, "Kourtney", "Kardashian");
                SiblingInfo si = new SiblingInfo(u1, u2);
                results.add(si);
            */
        } catch (SQLException e) {
            System.err.println(e.getMessage());
        }

        return results;
    }

    // Member Variables
    private Connection oracle;
    private final String UsersTable = FakebookOracleConstants.UsersTable;
    private final String CitiesTable = FakebookOracleConstants.CitiesTable;
    private final String FriendsTable = FakebookOracleConstants.FriendsTable;
    private final String CurrentCitiesTable = FakebookOracleConstants.CurrentCitiesTable;
    private final String HometownCitiesTable = FakebookOracleConstants.HometownCitiesTable;
    private final String ProgramsTable = FakebookOracleConstants.ProgramsTable;
    private final String EducationTable = FakebookOracleConstants.EducationTable;
    private final String EventsTable = FakebookOracleConstants.EventsTable;
    private final String AlbumsTable = FakebookOracleConstants.AlbumsTable;
    private final String PhotosTable = FakebookOracleConstants.PhotosTable;
    private final String TagsTable = FakebookOracleConstants.TagsTable;
}
